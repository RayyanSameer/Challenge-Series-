#!/usr/bin/env bash

set -euo pipefail 

error_exit(){
    echo "$1" >&2
    exit "${2:-1}" 
}

#WHAT : This is a disk usage monitor script that flags if a certain disk crosses our defined threshold

threshold=""


read -r -p "Enter a threshold :" threshold
if [[ -z $threshold ]]; then
    error_exit "You have'nt entered anything"
else 
    if [[ ! "$threshold" =~ ^[0-9]+$ ]] || [ "$threshold" -gt 99 ]; then
    echo "Not a valid threshold , Must be between 0 - 99 "
    else
        df -hP | awk -v t="$threshold" '
NR > 1 {
    sub(/%/, "", $5)
    if ($5 > t) print $6 " is at " $5 "% usage"
}'
        
    fi
fi 