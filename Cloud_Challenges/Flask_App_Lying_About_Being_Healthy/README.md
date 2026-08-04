# Incident Postmortem: Flask Lies About Being Healthy

**Type:** Docker / Observability Incident Simulation
**Pattern:** Observability Failure (Pattern 1) — the monitoring layer itself was lying about system state.

---

## 1. Incident

A Flask app with a required database dependency was run without its `DATABASE_URL` environment variable set. The container built and started successfully. The `/health` endpoint returned `200 OK`, but any actual API route returned `500 Internal Server Error`.

## 2. Detection

Diagnosed using only Docker's own tooling, no application code changes made during investigation:

```bash
# 1. Confirm the container is actually running
docker ps -a
# → Status: Running (not crashed, not restarting — rules out a startup failure)

# 2. Check application logs for errors
docker logs busted_app
# → No DATABASE_URL referenced anywhere in startup logs; DB connection never attempted successfully

# 3. Confirm the env var is genuinely missing (not just failing to load)
docker inspect --format '{{.Config.Env}}' busted_app
# → DATABASE_URL absent from the container's environment entirely
```

## 3. Root Cause

The `/health` endpoint only checked that the Flask process was alive and responding — it never verified the database connection. This allowed the container to report healthy to any orchestrator or load balancer while being functionally broken for every real request that touched the database.

## 4. Fix

- Re-ran the container with `DATABASE_URL` passed via `--env-file` at **runtime**, not baked into the image. A database connection string carries credentials and should be treated as a secret — never committed to source control or added via a Dockerfile `ENV` instruction, since that bakes it permanently into image history.
- Rewrote `/health` to actively ping the database and return `503` if unreachable, `200` only when both the app process **and** its dependency are confirmed live.

```python
@app.route('/health')
def health():
    try:
        db.session.execute('SELECT 1')
        return jsonify({"status": "healthy"}), 200
    except Exception:
        return jsonify({"status": "unhealthy", "reason": "database unreachable"}), 503
```

## 5. Prevention

- **Health checks must validate real dependencies, not just process liveness.** A health check that only confirms "the process is running" gives false confidence and hides the exact class of failure that matters most in production.
- **Add a deploy-time smoke test** in CI/CD that hits `/health` *and* a real data-dependent route before marking a deploy successful — a shallow health check alone can't be trusted to catch this.
- **Fail fast on missing required config.** Required environment variables (like `DATABASE_URL`) should raise an error immediately at startup rather than allowing the app to start and fail silently on the first real request.

## 6. Pattern

**Pattern 1 — Observability failure.** The system's own monitoring reported healthy while being broken. This is one of the most dangerous failure modes in production because it actively hides the problem from the tooling meant to catch it.