markdown
# Docker Incident Postmortems — Day 2 (Breaks 3–5)

Three more deliberate breaks, diagnosed with OCAT (Observe → Correlate → Analyse → Test). Continuation of the Docker re-familiarization sprint.

---

## Incident 3 — Network Isolation (DNS Resolution Failure)

**Date:** July 31, 2026

### Setup
```bash
docker network create net-a
docker network create net-b
docker run -d --name db --network net-a redis:alpine
docker run -it --name client --network net-b python:3.11-slim python -c "
import socket
print(socket.gethostbyname('db'))
"
```
Two containers placed on two separate custom Docker networks.

### Observe

socket.gaierror: [Errno -3] Temporary failure in name resolution

`docker ps -a` confirmed both containers existed and were created successfully — the failure was not a missing container, but a resolution failure.

### Correlate
```bash
docker network inspect net-a
docker network inspect net-b
```
`net-a` showed `db` present and alive. `net-b` showed no containers at all. Different subnets, no overlap.

### Analyse
Docker's embedded DNS only resolves hostnames for containers sharing the **same** network. `client` and `db` had no common network, so `db` was invisible to `client` by design — the error was confirmation that isolation was working correctly, not a fault.

### Test / Fix
```bash
docker network connect net-a client
```
Connected `client` to `net-a` in addition to `net-b`. Re-ran the resolution check — succeeded.

### Issues Faced
- Container name conflict (`/client` already in use) when re-running after a failed attempt — resolved with `docker rm <id>` before rerun; `--rm` on throwaway test containers avoids this entirely.
- Needed help interpreting raw `network inspect` JSON output the first time.

### Root Cause
`client` and `db` were placed on two networks with no shared scope, so Docker's per-network DNS had nothing to resolve.

### Pattern
Network-layer isolation — this is Docker working exactly as intended. The "fix" is a deliberate connectivity decision (shared network), not a bug fix.
