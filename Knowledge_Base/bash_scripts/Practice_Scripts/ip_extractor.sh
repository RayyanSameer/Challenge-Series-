#!/usr/bin/env bash
set -euo pipefail
LOGFILE="${1:?Usage: $0 <access_log>}"

echo "COUNT  IP"
awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -rn | head -10