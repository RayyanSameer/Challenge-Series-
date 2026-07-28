#!/usr/bin/env bash
set -euo pipefail

error_exit() {
    echo "Error: $1" >&2
    exit "${2:-1}"
}


if [[ $# -ge 1 ]]; then
    logfile="$1"
else
    read -r -p "Enter logfile path: " logfile
fi

if [[ ! -f "$logfile" ]]; then
    error_exit "File '$logfile' does not exist." 1
fi

error_count=0
warn_count=0
info_count=0

while IFS= read -r line; do
    if [[ "$line" == *ERROR* ]]; then
        ((error_count++))
    elif [[ "$line" == *WARNING* ]]; then
        ((warn_count++))
    elif [[ "$line" == *INFO* ]]; then
        ((info_count++))
    fi
done < "$logfile"


echo "=== Log Analysis Report ==="
echo "Errrors   : $error_count"
echo "Warning: $warn_count"
echo "Info     : $info_count"