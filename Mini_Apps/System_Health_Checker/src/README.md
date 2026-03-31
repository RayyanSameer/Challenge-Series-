Dockerized Real-Time System Health Monitor
 Project Overview

A containerized, full-stack monitoring application that tracks system resource usage (CPU, Memory, and Disk) in real-time. The application utilizes a Python/Flask backend to interface with the host operating system, a Redis in-memory datastore to maintain a rolling history of metrics, and a vanilla JavaScript frontend for data visualization.

The entire stack is orchestrated using Docker Compose, ensuring seamless communication across isolated container networks.
 Tech Stack

    Backend: Python, Flask, psutil (System Metric Hook)

    Database: Redis (In-Memory Data Structure Store)

    Frontend: HTML5, CSS3, Vanilla JavaScript (Fetch API)

    DevOps/Infrastructure: Docker, Docker Compose

 Key Features

    Real-Time Live Polling: The frontend automatically polls the backend API every 5 seconds to update the active health dashboard.

    On-Demand History: Stores a rolling log of the last 10 metric snapshots in Redis (lpush / ltrim). To optimize performance, the history table only fetches and renders when the user explicitly clicks the "Refresh Now" button.

    Proportional UI: Built a responsive, flat-design dashboard utilizing CSS table-layout for clean data presentation.

    Containerized Networking: Services communicate securely over Docker's internal DNS, with only the Flask API exposed to the host machine.

 Quick Start / Deployment
Prerequisites

    Docker and Docker Compose installed on your machine.

Run the Application

    Clone the repository and navigate to the src directory containing the docker-compose.yml.

    Build and start the containers:
    Bash

    docker-compose up --build

    Open your browser and navigate to: http://localhost:5000

Teardown & Hard Reset

To stop the application and wipe cached image layers (useful for applying frontend changes):
Bash

docker-compose down --rmi all
# To wipe Redis data as well:
docker-compose down -v

 Bug Log & Troubleshooting (War Stories)

Building this project involved solving several cross-layer infrastructure challenges. Here are the core issues encountered and how they were resolved:
Symptom / Error	Root Cause	The Solution
psutil pip install failed (exit code 1)	The psutil Python library requires C-headers to compile OS-level hooks inside a slim Linux Docker image.	Added gcc and python3-dev to the Dockerfile build steps before running pip install.
Frontend unreachable (localhost:5000 refused)	Flask defaults to binding to 127.0.0.1, making it inaccessible from outside the Docker container.	Configured Flask to listen on 0.0.0.0, mapping it to the container's external-facing network interface.
Redis ConnectionError	The Flask app was trying to connect to localhost:6379, which pointed to the Flask container itself, not the Redis container.	Updated the Redis connection string in app.py to use Docker's internal DNS (e.g., host='redis').
updateHistory is not defined (Console Error)	Docker's build cache was serving a stale version of logic.js, preventing new JS functions from being parsed by the browser.	Executed docker-compose down --rmi all to nuke the cache and force a fresh file copy, followed by a Hard Browser Refresh (Ctrl+F5).
NetworkError / OpaqueResponseBlocking	"Zombie" Docker containers were silently squatting on port 5000, causing the browser to abort the connection.	Killed the hanging processes with a forced Docker teardown and pruned the internal network before rebuilding.
 Directory Structure
Plaintext

📦 System_Health_Checker
 ┣ 📂 src
 ┃ ┣ 📂 backend
 ┃ ┃ ┗ 📜 app.py           # Flask API and Redis logic
 ┃ ┣ 📂 frontend
 ┃ ┃ ┣ 📜 index.html       # Dashboard UI
 ┃ ┃ ┣ 📜 style.css        # UI Styling
 ┃ ┃ ┗ 📜 logic.js         # Fetch API and DOM manipulation
 ┃ ┣ 📜 Dockerfile         # Multi-stage build instructions
 ┃ ┣ 📜 docker-compose.yml # Container orchestration and ports
 ┃ ┗ 📜 requirements.txt   # Python dependencies