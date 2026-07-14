#!/usr/bin/env bash


#Given a CSV with columns: date, service, cost. Sum cost per service. Print sorted by total cost descending. Real use: AWS cost breakdown by service from a Cost Explorer export.
# WHAT: Sum AWS costs per service from CSV export
# HOW:  awk -F',' with associative array, sum in END block
# WHY:  One-pass cost aggregation without Python or spreadsheet

set -euo pipefail 

CSV_FILE="${1:?Usage: $0 <file.csv>}"
awk -F ',' 'NR > 1 {# Remove any potential carriage return characters
    gsub(/\r/, "", $3); 
    # Add the value to the array
    sums[$2] += $3 
} 
END { 
    for (s in sums) printf "%-10s %.2f\n", s, sums[s] 
}' "$CSV_FILE" | sort -k2 -rn


