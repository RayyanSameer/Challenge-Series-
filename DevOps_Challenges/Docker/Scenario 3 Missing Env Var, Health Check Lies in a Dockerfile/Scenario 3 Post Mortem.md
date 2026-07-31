
## Incident 4 — Missing Env Var, Health Check Lies

**Date:** July 31, 2026

### Setup
Flask app with a shallow `/health` (`return jsonify({"status": "healthy"}), 200` unconditionally) and an `/api/data` route that reads `os.environ['DATABASE_URL']` directly, crashing if unset.

### Observe
Initial build/run attempt failed with `pull access denied for break4, repository does not exist` — misleading at first glance, but the real cause was that `docker build` had not successfully produced a local image (wrong directory / build not completed before `docker run`).

### Correlate
Confirmed via `docker images | grep break4` that the image wasn't present locally. Once rebuilt correctly in the right directory with `app.py` and `Dockerfile` together, the container started — but curl requests hung with connection refused and no logs. Root cause: `app.py` was missing the actual `app.run(host="0.0.0.0", port=5000)` call, so Flask's process exited immediately after startup with nothing written to stdout.

### Analyse
Two separate problems stacked: (1) a build/pathing issue that looked like a registry auth issue, (2) a missing runtime entrypoint call in the app code itself. Neither was the "intended" break (missing `DATABASE_URL`) — both had to be cleared before the actual scenario could even run.

### Test / Fix — Operational
```bash
docker run -d -p 5000:5000 -e DATABASE_URL=postgres://fake --name break4run break4
```
Supplied the missing env var. `/api/data` started responding correctly.

### Test / Fix — Architectural (the real lesson)
Rewrote the shallow health check to actually verify its dependency before claiming healthy:
```python
@app.route('/health')
def health():
    if 'DATABASE_URL' not in os.environ:
        return jsonify({"status": "unhealthy", "reason": "DATABASE_URL missing"}), 503
    return jsonify({"status": "healthy"}), 200
```
Confirmed: without the env var, `/health` now correctly reports 503 instead of lying with 200.

### Root Cause
Shallow health check reported "healthy" unconditionally, masking a real dependency failure that only surfaced on the actual data route.

### Pattern
Observability failure — health checks that don't verify the thing they claim to check give false confidence to orchestrators and on-call engineers alike. This is the same failure class as Simulation 1 (Flask Lies About Being Healthy).
