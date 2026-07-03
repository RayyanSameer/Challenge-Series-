#!/usr/bin/env bash

set -euo pipefail

LOGFILE="${1:-sample.log}"
if [[ ! -f "$LOGFILE" ]]; then
    echo "There's no logfile"
    exit 1
fi

#Now we process the file line by line

while IFS= read -r line; do
    timestamp="${line:0:15}"
    rest="${line:16}"

    read -r hostname tag severity message <<< "$rest"
    printf "TIME=%-15s HOST=%-8s SEVERITY=%-8s MSG=%s\n" \
    "$timestamp" "$hostname" "$severity" "$message"

done < "$LOGFILE"