#!/bin/bash

set -euo pipefail 

FILE="${1:?Usage: $0 <textfile>}"


extract_email_domain=$(grep -oP '(?<=@)[a-zA-Z0-9.-]+' "$FILE")

echo "All extracted domains:"
echo "$extract_email_domain" 
echo "----------------------"

top_domains=$(echo "$extract_email_domain" | sort | uniq -c | sort -rn | head -n 5)

echo "Top offending domains:"
echo "$top_domains"