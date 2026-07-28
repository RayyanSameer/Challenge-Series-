#!/bin/bash
set -euo pipefail

error_exit(){
    echo "$1"
    exit "${2:-1}"
}


LOGFILE_PATH="/var/log/service_watch.log"

service_check(){
    if pgrep -x "$PROCESS" >/dev/null; then
        echo "$PROCESS is Running"
        exit 0
    else
        restart_service
        log_action    
        exit 0
    fi
}


restart_service(){
    /etc/init.d/"$PROCESS" start
}

log_action(){
    echo "$(date): '$PROCESS' Service restarted" >> $LOGFILE_PATH
}

PROCESS=""
read -p -r "Type the name of the specific sevice you are trying to restart: "  PROCESS
if [[ -z "$PROCESS" ]]; then
    error_exit "Service name can't be empty"
fi

service_check