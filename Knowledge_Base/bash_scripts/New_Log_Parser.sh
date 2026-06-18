#!/bin/bash
set -euo pipefail

LOGFILE="${1:-sample.log}"

CHOICE="${2:-}"

if [[ ! -f "$LOGFILE" ]]; then
    echo "Error: file not found — $LOGFILE" >&2
    exit 1
fi

while IFS= read -r line; do
    timestamp="${line:0:15}"
    rest="${line:16}"
    read -r hostname tag severity message <<< "$rest"
    printf "TIME=%-15s HOST=%-8s SEVERITY=%-8s MSG=%s\n" \
        "$timestamp" "$hostname" "$severity" "$message"
done < "$LOGFILE"