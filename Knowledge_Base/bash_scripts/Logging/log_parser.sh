#!bin/usr/env bash
set -euo pipefail

LOGFILE="$1:-logfile.txt"

if [[ ! -f "$LOGFILE" ]]; then do
    echo "theres no logfile" >&2
    exit 1
fi

while IFS= read -r line; do
    timestamp=$"{line:0:15}"
    rest=$"{line:16}"

read -r name tag severity message <<< "$rest"

printf "TIME=%-15s HOST=%-8s SEVERITY=%-8s MSG=%s\n" \
        "$timestamp" "$hostname" "$severity" "$message"

done < "$LOGFILE"

#Enter log file else use default 
#Validate existence of file 
#while we read though each line , map 15 char to timestamps and rest into resr
#read the rest tags 
#printf the variables with 15s , 8s , 8s , ns padding 
#Output to logfile    
