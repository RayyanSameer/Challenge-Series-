# Incident Analysis: Docker SIGTERM Handling & Delayed Shutdowns

## 1. Observation

- Running `time docker stop sigtermtest` consistently took ~10.1 seconds to complete.
- The container status eventually changed to `Exited (137)`.
- Subsequent attempts to run a container with the same name threw `Conflict` errors due to leftover stopped container states.

## 2. Correlation

- **Exit Code 137**: Indicates a process was forcefully killed by the Linux kernel via `SIGKILL` (Signal 9).
- **10-Second Delay**: Corresponds directly to Docker's default grace period (`--time=10`). Docker sends `SIGTERM`, waits 10 seconds for a clean shutdown, and falls back to `SIGKILL` if the process is still running.

## 3. Analysis

### Cause 1: Unreachable Signal Handler Code

In the original `app.py`, an active infinite loop preceded the registration of the `SIGTERM` handler:

```python
# Execution gets stuck in this loop
while True:
    time.sleep(1)

# NEVER REACHED: Signal registration below was dead code
signal.signal(signal.SIGTERM, handle_sigterm)
```

Because Python executes sequentially, execution was trapped in the loop before `signal.signal()` could register the handler.

### Cause 2: PID 1 Default Kernel Behavior

In Linux containers, the primary process runs as PID 1. PID 1 treats signal handling differently than standard processes:

- Standard Linux processes default to terminating upon receiving `SIGTERM`.
- PID 1 processes explicitly drop default signal dispositions. If no custom signal handler is actively registered before the signal arrives, `SIGTERM` is completely ignored.

## 4. Test

### A. Updated Code (`app.py`)

Re-ordered execution so the handler is registered before entering the polling loop:

```python
import signal
import sys
import time

def handle_sigterm(signum, frame):
    print("Received SIGTERM, shutting down cleanly...", flush=True)
    sys.exit(0)

# Register handler FIRST
signal.signal(signal.SIGTERM, handle_sigterm)

print("Running, awaiting SIGTERM...", flush=True)

# Single main loop
while True:
    time.sleep(1)
```

### B. Command Execution

```bash
docker rm -f sigtermtest
docker build -t sigtermtest .
docker run --rm -d --name sigtermtest sigtermtest
time docker stop sigtermtest
```

## 5. Result

- **Shutdown Time**: Decreased from 10.1s to < 0.5s.
- **Exit Code**: Clean exit (Code `0`) instead of being killed (Code `137`).
- **Container Lifecycle**: The `--rm` flag automatically cleaned up the container upon exit, preventing name conflicts on subsequent runs.

## Root Cause

A `SIGTERM` handler registered *after* an infinite blocking loop is dead code — it never executes, so the process falls back to PID 1's default behavior of ignoring `SIGTERM` entirely, forcing Docker to escalate to `SIGKILL` after the full grace period.

## Pattern

Graceful shutdown failure. This is the same failure class behind production incidents where deployments hang on rolling restarts — a process that can't be asked nicely to stop delays every deploy by the full grace period, every time.

## Key Takeaways

- Signal handlers must be registered **before** any blocking operation (loops, `input()`, long-running calls) — code after a `while True:` loop with no exit condition is unreachable, no matter how correct it looks on its own.
- PID 1 in a container does not inherit the same default signal behavior as an ordinary process — an explicit handler is required, not optional, if clean shutdown matters.
- A 10-second `docker stop` is not "just slow" — it's a specific, measurable signal that `SIGTERM` was never actually handled, escalating to a forced `SIGKILL`.
- `--rm` on throwaway test containers avoids the name-conflict friction hit during iterative debugging.
