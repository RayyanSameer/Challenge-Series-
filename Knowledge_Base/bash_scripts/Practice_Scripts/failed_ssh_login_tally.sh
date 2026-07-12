#!/bin/bash

#WHAT : This is a practice script that takes out the worst offending ip's that fail SSH , the output can be used tonotify admin for preemtive intervention.  
set -euo pipefail

LOGFILE="${1:?Usage: $0 <auth.log>}"
top_ips=$(grep -i "Failed Password" "$LOGFILE" | grep -oP 'from \K[0-9.]+' | sort | uniq -c | sort -rn | head -n 5)
echo "Top offending IPs:"
echo "$top_ips" 
