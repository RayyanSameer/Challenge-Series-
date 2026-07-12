#!/bin/bash

set -euo pipefail

error_exit(){
    echo "$1"
    exit "${2:-1}"
}

HOSTS=("google.com:443" "localhost:22" "1.1.1.1:80")

check_hosts(){
    local host="$1" port="$2"
    if nc -z -w2 "$host" "$port" 2>/dev/null; then
        echo "$host:$port is UP"
    else 
        echo "$host:$port is DOWN"   
    fi     
}

up=0
down=0

for entry in "${HOSTS[@]}"; do
    host="${entry%%:*}"
    port="${entry#*:}"

    if check_hosts "$host" "$port"; then
        ((up++))
    else
        ((down++))
    fi
done            

echo "summary: $up up $down down"