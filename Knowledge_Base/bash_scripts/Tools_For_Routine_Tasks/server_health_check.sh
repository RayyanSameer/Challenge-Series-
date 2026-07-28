#!/usr/bin/env bash
set -euo pipefail

REPORT_FILE="/tmp/health_report_$(date +%Y%m%d_%H%M%S).txt"

check_disk(){

    read -r -p "Enter Disk usage threshold (%): " threshold

    df -P | awk 'NR>1 {print $5, $1, $4}' | tr -d "%" | while read -r usage filesystem avail; do
    if [[ "$usage" -gt "$threshold" ]]; then
        echo "High Disk Usage on ${filesystem}: ${usage}% used (${avail} space free)"
        fi
    done 
}

check_cpu(){

    read -r -p "Enter CPU usage threshold (%): " threshold
    local cpu_idle cpu_usage
    cpu_idle=$(top -bn1 | awk '/%Cpu/ {print $8}' | cut -d. -f1)
    cpu_usage=$((100 - cpu_idle))

    if [[ "$cpu_usage" -gt "$threshold" ]]; then
        echo "High CPU Usage: ${cpu_usage}% (threshold: ${threshold}%)" 
    else
        echo "CPU Usage normal: ${cpu_usage}%" 
    fi
  
}


check_memory(){
    local threshold
    local mem_usage
    read -r -p "Enter memory usage threshold (%): " threshold
    mem_usage=$(free | awk '/Mem:/ {printf "%.0f", ($2 - $7)/$2 * 100}')

    if [[ "$mem_usage" -gt "$threshold" ]]; then
        echo "High Memory Usage: ${mem_usage}% (threshold: ${threshold}%)" 
    else
        echo "Memory Usage normal: ${mem_usage}%" 
    fi

}

check_failed_services(){
    local has_anything_failed
    has_anything_failed=$(systemctl --failed --no-legend)
    if [[ -z "$has_anything_failed" ]]; then
        echo "All services healthy"
    else
        echo "$has_anything_failed"  
    fi    
}

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi
generate_report(){
    local report
    report=$(
        echo "== Health Report: $(date) ==="
        echo "---Disk---"
        check_disk
        echo "---CPU---"
        check_cpu
        echo "---MEM---"
        check_memory
        echo "---SERVICE FAILURES---"
        check_failed_services

    )

     if [[ "$DRY_RUN" == true ]]; then
        echo "$report"
    else
        echo "$report" > "$REPORT_FILE"
        echo "Report written to $REPORT_FILE"
    fi
}


generate_report