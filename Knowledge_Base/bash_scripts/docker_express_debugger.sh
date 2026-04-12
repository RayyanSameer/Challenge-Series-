#!/bin/bash

#This script helps us debug why a docker container is not starting. It works by getting the exit code of the container and then getting the logs of the container along with port bindings and environment variables and a final OOM check.

set -euo pipefail

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"

}

[[ $# -ne 1 ]] && error_exit "Usage: $0 <container_name_or_id>"
CONTAINER=$1

if ! docker inspect "$CONTAINER" > /dev/null 2>&1; then
    error_exit "Container not found: $CONTAINER"
fi

echo "=== Checking status of container: $CONTAINER ==="

exec > >(tee -i "debug_$(date +%F).log") 2>&1
EXIT_CODE=$(docker  inspect "$CONTAINER" --format='{{.State.ExitCode}}')
echo "Exit Code: $EXIT_CODE"

case $EXIT_CODE in
    0)
        echo "Success: Container exited normally.";;
    1) 
        echo "Error: Container exited with a general error.";;
    137)
        echo "Error: Container was killed (possibly OOM). Inspecting dmesg for OOM events..."
        dmesg | grep -i 'killed process' | tail -5 ;;
    *)
        echo "Error: Container exited with code $EXIT_CODE.";;
esac        
     
echo "Getting logs from container $CONTAINER..." 
docker logs "$CONTAINER" 2>&1 grep -iE "error/execption/fail/fatal" | tail -20

echo "Getting port bindings for container $CONTAINER..."
docker inspect "$CONTAINER" --format='{{json .NetworkSettings.Ports}}' | python3 -m json.tool 2>/dev/null


echo "Getting environment variables for container $CONTAINER..."
docker inspect "$CONTAINER" --format='{{range .Config.Env}}{{println .}}{{end}}' | sed 's/=.*/=***MASKED***/'

echo ""
echo ""
echo "=== OOM CHECK ==="
docker stats "$CONTAINER" --no-stream --format "Memory: {{.MemUsage}}"

echo "Debugging complete. Check the log file debug_$(date +%F).log for details."
echo "Would you like to restart the container? (y/n)"
read -r RESTART
if [[ "$RESTART" == "y" ]]; then
    docker restart "$CONTAINER"
    echo "Container restarted. Check logs for any new issues."
else
    echo "Container not restarted. Please investigate the log file for details."
fi


