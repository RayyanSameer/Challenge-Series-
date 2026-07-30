#!/bin/bash

#A script to check service health and restart automatically

echo "===== SERVICE HEALTH CHECK ======"

check_status(){

    local service="$1"
    if pgrep -x "$service" > /dev/null; then
    echo "$service is RUNNING"
else
    echo "$service is NOT RUNNING"
    echo "ATTEMPTING RESTART"
    sudo systemctl restart "$service"
    fi

}

if [[ $# -ne 1 ]]; then
    echo "Usage: $1 <service_name>" >&2
    exit 1
fi   

echo "===== SERVICE HEALTH CHECK ======"
echo "CHECKING HEALTH FOR SERVICE: $1"

check_status "$1"






