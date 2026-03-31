


# 3-Tier System Monitor (Python + Redis + Nginx)

This project is a lightweight, full-stack monitoring solution designed to track system metrics (CPU, Memory, Disk) and visualize them in a web browser. It follows a decoupled 3-tier architecture and uses **Terraform** for automated infrastructure provisioning.

---

##  Architecture Overview

The application is split into three distinct layers:

1.  **Tier 1 — Frontend (Nginx):** A static HTML/JavaScript dashboard. Nginx serves the frontend and acts as a reverse proxy to the backend API.
2.  **Tier 2 — Backend (Flask API):** A Python REST API that collects real-time system metrics using the `psutil` library.
3.  **Tier 3 — Data (Redis):** An in-memory data store that caches the last 10 readings to provide historical context.
4.  **Infrastructure (Terraform):** Automated deployment scripts to provision the necessary cloud environment (VPC, Security Groups, Instances).

---

##  Project Structure

```text
.
├── backend/
│   ├── app.py                 # Flask API logic
│   └── requirements.txt       # Python dependencies
├── frontend/
│   ├── index.html             # Dashboard UI
│   └── style.css              # UI Styling
├── infrastructure/            # Terraform IaC
│   ├── main.tf                # Provider & Resource definitions
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # DNS/IP Outputs
│   └── terraform.tfvars       # Sensitive/Local values
├── nginx/
│   └── default.conf           # Reverse proxy configuration
└── docker-compose.yml         # Local Orchestration (Optional)
```

---

##  Getting Started

### 1. Provision Infrastructure
Navigate to the infrastructure folder to spin up your cloud environment via Terraform:
```bash
cd infrastructure/
terraform init
terraform plan
terraform apply
```

### 2. Application Deployment
Once the infrastructure is ready (e.g., an EC2 instance or ECS cluster), deploy the containers:
```bash
# If using Docker Compose on the provisioned host
docker-compose up -d --build
```
The dashboard will be available at the public IP/DNS provided by the `terraform output`.

---

##  Tech Stack

* **IaC:** Terraform (AWS/Cloud Provider)
* **Backend:** Python 3.12, Flask, `psutil`
* **Data:** Redis (Caching layer)
* **Proxy/Web:** Nginx
* **Containerization:** Docker

---

##  API Endpoints

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/api/metrics` | `GET` | Returns current CPU, RAM, and Disk usage. |
| `/api/history` | `GET` | Returns the last 10 cached readings from Redis. |

---

##  License
Distributed under the MIT License. See `LICENSE` for more information.
```