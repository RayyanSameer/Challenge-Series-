
## Incident 5 — Stale Image Cache (Attempted)

**Date:** July 31, 2026

### Setup
```bash
mkdir break5 && cd break5
echo "print('version 1')" > app.py
# Dockerfile: FROM python:3.11-slim, WORKDIR /app, COPY app.py ., CMD ["python","app.py"]
docker build -t break5 .
docker run --rm break5    # prints "version 1"
echo "print('version 2')" > app.py
docker build -t break5 .
docker run --rm break5
```

### Observe
Second run correctly printed `version 2` — no staleness occurred.

### Analyse
`COPY` is content-hash-aware: Docker checksums the file at build time and compares against the prior build. Because the file content genuinely changed, the layer correctly invalidated and rebuilt. This scenario doesn't reliably reproduce staleness because `COPY` is specifically designed to catch this case.

### Where Staleness Actually Bites (noted, not reproduced)
Real-world stale-cache incidents are usually not a local `COPY` failure — they come from pinning deployments to an old `:latest` tag or digest in a registry/CI pipeline, where a rebuild was assumed to have happened but didn't propagate. That's a CI/CD-layer trap (relevant in the Week 6 pipeline phase), not a local Docker build trap.

### Fallback Command (correct instinct, unused this time)
```bash
docker build --no-cache -t break5 .
```
Confirmed as the correct escape hatch for any case where a rebuild *should* reflect a change and doesn't.

### Pattern
Negative result — confirms understanding of how `COPY` cache invalidation actually works, rather than producing a break. Genuine staleness requires a registry/tag-pinning scenario to reproduce properly.

---

## Key Takeaways — Day 2

- **Confirm the image exists locally (`docker images`) before troubleshooting a "pull access denied" error** — that error usually means the build never completed, not an auth problem.
- **A container with no logs and connection-refused often means the main process exited immediately** — check that the app's actual entrypoint call (e.g. `app.run(...)`) is present, not just the route definitions.
- **DNS resolution failures between containers are frequently isolation working as intended**, not a bug — verify network membership with `docker network inspect` before assuming something's broken.
- **Shallow health checks are a real production risk** — a health check must verify its dependencies, not just return a hardcoded success.
- **Not every "break" reproduces on the first try** — `COPY`'s content-hash caching is robust; genuine stale-cache traps live at the registry/CI layer, not the local build layer.