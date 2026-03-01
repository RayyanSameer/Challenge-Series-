#!/bin/bash
# Description: Monitors website uptime from a list of URLs

error_exit() {
    echo "$1" >&2
    exit "${2:-1}"
}

[[ $# -ne 1 ]] && error_exit "Usage: $0 <url_list_file>" 1
SITES_FILE="$1"
[[ ! -f "$SITES_FILE" ]] && error_exit "Error: File '$SITES_FILE' not found." 1


ANY_FAILED=0


while IFS= read -r URL || [[ -n "$URL" ]]; do

    [[ -z "$URL" || "$URL" =~ ^# ]] && continue

    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL")


    if [[ "$STATUS" == "200" ]]; then
        echo "[OK]   $URL"
    else
        echo "[FAIL] $URL (Status: $STATUS)" >&2
        ANY_FAILED=1
    fi
done < "$SITES_FILE"

exit $ANY_FAILED