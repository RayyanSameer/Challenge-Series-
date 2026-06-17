#!/bin/bash
# SRE Service Auditor - Production Grade

set -euo pipefail

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

if [[ $# -ne 1 ]]; then
    error_exit "Usage: $0 <process_name>" 1
fi    

PROCESS="$1"


if PID=$(pgrep -x "$PROCESS"); then
  
    UPTIME=$(ps -o etime= -p "$PID" | tr -d ' ')
    echo "[OK] Service $PROCESS is running (PID: $PID, Uptime: $UPTIME)"
else
    echo "[CRITICAL] Service $PROCESS is down!" >&2
    
    exit 2
fi


read -r -p "Enter Expected Port (e.g. 8080): " PORT_NUMBER

if sudo ss -ltnp | grep -q ":$PORT_NUMBER.*pid=$PID"; then
    echo "[OK] Service is listening on port $PORT_NUMBER"
else
    echo "[WARN] Port Mismatch! Process $PID is not on port $PORT_NUMBER"
fi


read -r -p "Enter Health URL (e.g. http://localhost:8080/health): " HEALTH_URL


HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 "$HEALTH_URL" || echo "000")

if [[ "$HTTP_STATUS" -ge 200 && "$HTTP_STATUS" -lt 300 ]]; then
    echo "[OK] Health Check: HTTP $HTTP_STATUS"
elif [[ "$HTTP_STATUS" -ge 500 ]]; then
    echo "[CRITICAL] Health Check: HTTP $HTTP_STATUS (Server Error)"
else
    echo "[UNKNOWN] Health Check: HTTP $HTTP_STATUS"
fi


LATENCY=$(curl -s -o /dev/null -w "%{time_total}" --max-time 2 "$HEALTH_URL")

if (( $(echo "$LATENCY > 2.0" | bc -l) )); then
    echo "[DEGRADED] Response time is too slow: ${LATENCY}s"
else
    echo "[OK] Latency: ${LATENCY}s"
fi