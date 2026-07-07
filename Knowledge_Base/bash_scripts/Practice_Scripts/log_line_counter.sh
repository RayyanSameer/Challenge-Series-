#!/bin/bash
set -euo pipefail
error_exit(){
    echo "$1" >&2
    exit ${"2:-1"}
}

logfile="$1:? Usage: $0 <logfile>"
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
done

echo "ERRORS : $error_count"
echo "WARNINGS : $warn_count"
echo "INFO : $info_count"