#!/bin/bash
# WHAT : Modular system health checker with pre-check functions
# HOW : Each check is a function returning 0/1 , main collects results 
# WHY : Modular design lets you add/remove checks without touching the core 

set -euo pipefail

check_disk(){
    local threshold="$1"
    local usage 
    usage=$(df / | awk 'NR==2{print $5}' | tr -d '%')
    if [[ "$usage" -gt "$threshold" ]]; then
        echo "DISK USAGE HIGH ($usage %)"
        return 1 
    else
        echo "DISK : OK $usage"
        return 0
    fi        
}

check_memory(){
    local threshold="$1"
    local usage 
    usage=$(free | awk '/Mem/{printf "%.0f" , $3/$2*100}')
    if [[ "$usage" -gt "$threshold" ]]; then
        echo "MEMORY USAGE is HIGH: $usage"
        return 1
    else
        echo "MEMORY USAGE is fine : $usage"
        return 0
    fi


}



check_services(){
    local services=("nginx" "cron")
    local status=0
    for svc in "${services[@]}"; do
        if pgrep -x "$svc" >/dev/null; then
            echo "Service is running"
        else
            echo "Service is not"
            exit 1
        fi   
    done
    return $status         
}


#Checks 
function_checks(){
    local failures=0
    trap 'failures=$((failures+1))' ERR

    check_disk 76 || true
    check_memory 82 || true
    check_services || true
    
    echo "====================================================="

    if (( failures > 0 )); then
        echo "$failures function(s) failed."
    exit 1
    else
        echo "All functions succeeded."
        exit 0
    fi    

}

function_checks

