#!/bin/bash
set -euo pipefail 

error_exit(){
    echo "$1"
    exit "${2:-1}"
}

services=("nginx" "cron")

restart_service(){
    local svc="$1"
    sudo systemctl restart "$svc"
}

log_action(){
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> logfile.txt

}

check_services(){
    for svc in "${services[@]}"; do
        if  systemctl is-active --quiet "$svc"; then
            echo "$svc is Running"
        else
            restart_service "$svc"
            log_action "Restarted $svc"
        fi
    done            
}
check_services