# Docker Incident Postmortems — Deliberate Breaks

Two containers broken on purpose, diagnosed using the OCAT method (Observe → Correlate → Analyse → Test), and fixed. Part of a Docker re-familiarization sprint focused on debugging speed, not just syntax.

---

## Incident 1 — Capped Memory Kill (Exit 137)

**Date:** July 30, 2026

### Setup
```bash
docker run --memory=50m --name break1 python:3.11-slim python -c "
x = []
while True:
    x.append('a' * 10**6)
"
```
An unbounded memory-growth script run inside a container hard-capped at 50MB.

### Observe
```bash
docker ps -a
```
Container status: `Exited (137)` — signal 9 (SIGKILL), forcefully terminated.

### Correlate
```bash
docker logs --tail 100 break1
```
No logs produced. The kill was instant — the kernel terminated the process before it could write anything to stdout/stderr.

### Analyse
```bash
docker inspect break1 --format '{{.State.OOMKilled}}'
```
Result: `true`. Confirmed root cause: the container exceeded its memory limit and was OOM-killed by the kernel, not an application-level crash.

### Test / Fix
```bash
docker rm -f break1
docker run --memory=150m --name break1 python:3.11-slim python
```
Raised the memory ceiling. Container exited cleanly (code 0).

### Root Cause
Memory limit (`--memory=50m`) too low for the process's actual memory demand.

### Fix
Increased `--memory` allocation. (Alternative real-world fix: inspect and patch the memory leak rather than just raising the ceiling.)

### Pattern
Resource-limit failure — cgroups enforcing a hard memory cap. Exit code 137 should always be read as "check `OOMKilled` first," not diagnosed from logs alone, since a true OOM kill often produces no log output at all.

---

## Incident 2 — Bad CMD (Exit 127)

**Date:** July 30, 2026

### Setup
```dockerfile
FROM python:3.11-slim
CMD ["python", "nonexistent_script.py"]
```
```bash
docker build -t break2 .
docker run --name break2run break2
```

### Observe / Correlate
```bash
docker logs break2run
```
```
python: can't open file '//nonexistent_script.py': [Errno 2] No such file or directory
```
CMD referenced a file that was never copied into the image.

### Analyse
```bash
docker run --rm -it --entrypoint sh break2
```
Dropped into a shell inside the image (overriding the broken CMD) and confirmed via `ls` that the file genuinely did not exist in the filesystem.

### Test / Fix
Added a real file and pointed `CMD` at it:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY hello_world.py .
CMD ["python", "hello_world.py"]
```
Initial rebuild appeared to not pick up the change — resolved with a forced clean rebuild:
```bash
docker rm break2run
docker build --no-cache -t break2 .
docker run --rm --name break2run break2
```
Container ran successfully, printed `Hello World`, exited clean.

### Root Cause
`CMD` pointed at a script that was never included in the image's filesystem layer.

### Fix
Added the missing file via `COPY`, updated `CMD` to reference it, forced a clean rebuild with `--no-cache` to guarantee the new layer was picked up.

### Pattern
Process-layer failure (bad `CMD`/`ENTRYPOINT`) combined with a build-cache gotcha. Exit 127 = command not found — always confirm via `docker logs` first, then use `--entrypoint sh` to inspect the actual filesystem when the error isn't self-explanatory.

---

## Key Takeaways

- **Exit code first, but never exit code alone.** 137 and 127 both point toward a category of failure, but confirmation requires a second command (`OOMKilled` field, or entering the container to check the filesystem).
- **`docker rm -f <name>` before rerunning** during iterative debugging — name conflicts are constant when breaking/fixing containers repeatedly.
- **`--no-cache` is the escape hatch** when a rebuild should reflect a change and doesn't appear to.
- **OCAT discipline matters more than the fix itself** — both incidents were solved fastest by following Observe → Correlate → Analyse → Test in order rather than jumping straight to a fix attempt.