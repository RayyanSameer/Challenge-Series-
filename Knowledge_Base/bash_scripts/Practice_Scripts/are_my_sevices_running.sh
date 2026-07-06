#!/bin/bash
set -euo pipefail

error_exit(){
    echo "$1" >&2
    exit "${2:-1}" 
}

services=("nginx" "cron" "sshd")
for svc in "${services[@]}"; do
    if systemctl is-active --quiet "$svc"; then
        echo "$svc is UP"
    else
        echo "$svc is DOWN"
    fi
done            