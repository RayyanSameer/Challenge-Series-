# Docker Scenario 7 - Unbounded Disk Growth (Two Distinct Failure Modes)

Started as one scenario (log flood filling disk) but surfaced a second, genuinely different
failure mode along the way: a container writing directly to its own writable layer, which
Docker's log-rotation flags do nothing to fix. Documenting both, since they teach different
lessons and need different fixes.

## Part A - Log Flood (stdout growth, json-file log driver)

### Setup

    docker run -d --name logflood python:3.11-slim python -c "
    import time
    while True:
        print('log line filler ' * 50)
        time.sleep(0.01)
    "

### Observe
`docker system df` showed total disk usage climbing steadily, fast enough to be genuinely
alarming ("scary fast, I'll run out of space soon").

### Correlate
    docker inspect --format='{{.LogPath}}' logflood
    sudo ls -lh <logpath>

The JSON log file itself was growing directly on the host - confirmed the growth was coming
from container stdout, captured by Docker's default `json-file` log driver.

### Analyse
Docker's default logging driver has no size cap out of the box. A container that logs
verbosely and never stops will fill host disk indefinitely, with no warning anywhere in
`docker ps` or `docker logs`.

### Test / Fix
    docker rm -f logflood
    docker run -d --name logflood \
      --log-opt max-size=10m --log-opt max-file=3 \
      python:3.11-slim python -c "
    import time
    while True:
        print('log line filler ' * 50)
        time.sleep(0.01)
    "

`--log-opt max-size=10m --log-opt max-file=3` caps the active log file at 10MB, keeps up to
3 rotated files (~30MB total ceiling), and deletes the oldest file once a 4th would be created.
Confirmed via `docker system df` returning to a stable baseline after the fix.

### Root Cause
No log rotation configured - Docker's default `json-file` driver has no built-in size limit.

### Pattern
Unbounded stdout logging. This is normally set once, globally, at the Docker daemon level
(`/etc/docker/daemon.json`) in real deployments rather than per-container, so every container
inherits the cap automatically.

---

## Part B - Writable-Layer Disk Fill (separate, harder problem)

### Setup

    docker run -d --name diskflood python:3.11-slim python -c "
    with open('/tmp/heavy_file.txt', 'a') as f:
        while True:
            f.write('x' * 1024 * 1024)  # 1MB chunks
    "

### Observe
`docker system df` climbed rapidly, same alarming rate as Part A - but the mechanism turned
out to be entirely different.

### Correlate
    docker inspect --format='{{.LogPath}}' diskflood
    sudo ls -lh <logpath>

Result: the log file was **0 bytes**. This was the critical signal - if disk usage is
climbing but the log file isn't growing, the growth isn't coming from logging at all.

### Analyse
This script never calls `print()` - it writes directly to a file (`/tmp/heavy_file.txt`)
inside the container's own writable layer. Docker's log driver has nothing to do with this;
`--log-opt` flags do not apply here at all. The disk growth was the writable layer itself
filling with the file's contents.

### Test / Fix
    docker rm -f diskflood

Unlike log rotation, Docker does not have one universal, always-available flag to cap
writable-layer growth - this is a genuinely harder problem than Part A. Realistic production
approaches:
- Don't let containers write unbounded data to ephemeral storage at all - use a size-capped
  volume instead and monitor it.
- `--storage-opt size=` can cap writable-layer size, but only works with specific storage
  drivers/filesystem combinations (not universal - needs to be verified per host).
- Application-level: cap the write loop with an explicit max-size check in the code itself.

### Root Cause
Application wrote unbounded data directly to the container's writable filesystem layer, with
no log driver involved and no default Docker mechanism to cap it.

### Pattern
Ephemeral storage exhaustion - a different failure class from log flooding, even though the
symptom (`docker system df` climbing fast) looked identical at first glance.

---

## Key Takeaways

- Two failures can present with an identical symptom (`docker system df` growing fast) and
  have completely different root causes and fixes - always correlate to the actual mechanism
  (in this case, the log file) before assuming which fix applies.
- A 0-byte log file while disk usage climbs is itself a diagnostic finding - it rules out
  logging as the cause and should redirect investigation, not be treated as a dead end.
- `--log-opt max-size`/`max-file` only caps stdout/stderr captured by Docker's log driver -
  it does nothing for data an application writes directly to its own filesystem.
- Writable-layer disk exhaustion has no single universal fix at the Docker level - it needs
  to be prevented architecturally (volumes with real limits, or application-level caps).