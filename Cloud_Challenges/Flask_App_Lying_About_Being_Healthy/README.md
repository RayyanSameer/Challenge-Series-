# 🚨 Flask Incident Simulation — Healthy but Broken System

## 📌 Overview

This project simulates a real-world DevOps failure scenario where:

> The system reports **healthy (200 OK)**
> But users experience **failures (500 errors)**

It demonstrates how **shallow health checks can silently mask critical issues**, leading to misleading observability and production incidents.

---

## 🛠️ Tech Stack

* Python (Flask)
* Docker
* Environment-based configuration

---

## 🧱 Project Structure

```
.
├── Dockerfile
├── requirements.txt
└── app/
    └── shallow_health_check_app.py
```

---

## ⚙️ How It Works

### Endpoints

* `/health` → returns 200 if process is alive (shallow check)
* `/api/users` → depends on database initialization

---

## 🚀 Getting Started

### 1. Build the Image

```bash
docker build -t flask-incident .
```

---

### 2. Run (Working Version)

```bash
docker run -d -p 5000:5000 \
-e DATABASE_URL=postgres://localhost/mydb \
--name working-app flask-incident
```

### Expected:

* `/health` → 200 OK ✅
* `/api/users` → 200 OK ✅

---

### 3. Run (Broken Scenario)

```bash
docker run -d -p 5000:5000 \
--name broken-app flask-incident
```

### Expected:

* `/health` → 200 OK ⚠️
* `/api/users` → 500 ERROR ❌

---

## 🔍 Observed Behavior

| Endpoint     | Status    |
| ------------ | --------- |
| `/health`    | 200 OK    |
| `/api/users` | 500 ERROR |

### Logs

```
RuntimeError: Database not initialised
```

---

## 🧠 Root Cause

* `DATABASE_URL` environment variable is missing
* Database connection is not initialized
* Application fails at runtime
* Health check remains unaffected

---

## 🚨 The Core Problem

The system reports:

> “I am healthy”

But in reality:

> “I cannot serve user requests”

This is a **false positive health signal**.

---

## 🔧 Fix

### Option 1: Provide Required Environment Variable

```bash
docker run -d -p 5000:5000 \
-e DATABASE_URL=postgres://localhost/mydb \
--name fixed-app flask-incident
```

---

### Option 2: Implement Deep Health Check

```python
@app.route('/health')
def health():
    if not DB_CONNECTION:
        return jsonify({"status": "error"}), 500
    return jsonify({"status": "ok"}), 200
```

---

## 📉 Failure Timeline (What Went Wrong During Setup)

This project involved debugging across multiple layers:

* Incorrect Docker build command (missing context)
* CLI typos (`ocker run`)
* Container exiting due to wrong file path
* Filesystem mismatch inside container (`/app/app/...`)
* Invalid `docker run` command override (`.`)
* Flask route misconfiguration (missing `/`)
* Missing environment variable causing runtime failure

---

## 🎯 Key Learnings

### 1. Containers Run Processes, Not Systems

If the main process exits → container stops

---

### 2. Logs Are the Source of Truth

Every failure was visible in logs

---

### 3. File Paths Matter Inside Containers

Container filesystem ≠ local filesystem

---

### 4. Health Checks Must Validate Dependencies

Shallow checks can hide critical failures

---

### 5. “Running” ≠ “Working”

A system can be:

* Up ✅
* Healthy ❌
* Functionally broken ❌

---

## 🚀 Real-World Relevance

This pattern can cause:

* Load balancers routing traffic to broken instances
* Monitoring systems missing critical failures
* Increased user-facing errors despite “healthy” dashboards

---

## 🧠 Final Takeaway

> A system that lies about being healthy is more dangerous than one that fails loudly.

---

## 🔭 Future Improvements

* Add structured logging
* Introduce readiness/liveness probes
* Integrate real database checks
* Use proper secret management (AWS Secrets Manager, etc.)

---
