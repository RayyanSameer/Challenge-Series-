#!/bin/bash
#WHAT : a tiny script to read an error log and pull out all 4xx/5xx status codes, extracts the IP and status code only, counts occurrences per IP, sorted descending

set -euo pipefail

LOGFILE_PATH=""
read -r -p "Enter path to logfile: " LOGFILE_PATH

if [[ -z "$LOGFILE_PATH" ]]; then
    echo "Error: You have not entered anything." >&2
    exit 1
fi


if [[ ! -f "$LOGFILE_PATH" ]]; then
    echo "Error: The file '$LOGFILE_PATH' does not exist." >&2
    exit 1
fi

grep -E '" [45][0-9]{2} ' "$LOGFILE_PATH" | awk '{print $1}' | sort | uniq -c | sort -rn | tee triage_output.txt
