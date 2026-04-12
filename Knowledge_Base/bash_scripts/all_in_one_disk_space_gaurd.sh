#!/bin/bash

#Script to monitor disk space and send alert when it goes above a certain threshold. It also logs the disk usage to a file for historical analysis, and also has a cleanup function that can be triggered to free up space by compressing old log files. and filters out the top 10 largest files in the directory to help identify space hogs.

#This is a combination of multiple scripts that I have written in the past for disk space monitoring, log management, and file cleanup. I have combined them into one script to make it more efficient and easier to manage.

#This script can be scheduled to run as a cron job to automate the monitoring and cleanup process.

set -euo pipefail

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

[[ $# -ne 2 ]] && error_exit "Usage: $0 <threshold_percentage> <disk_path>"
THRESHOLD=$1

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    error_exit "Threshold must be a number."
fi

DISK_PATH=$2

if [[ ! -d "$DISK_PATH" ]]; then
    error_exit "Disk path not found: $DISK_PATH"
fi


LOG_FILE="disk_usage.log"

echo "Starting Disk Space Guard Script"
echo "List of disks mounted on the system:"
df -h
echo "Choosing disk to monitor: $DISK_PATH"

USAGE=$(df -P "$DISK_PATH" | tail -1 | awk '{print $5}' | tr -d '%')
echo "Current disk usage of $DISK_PATH: ${USAGE}%"
if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "ALERT: Disk usage is at ${USAGE}% (Threshold: ${THRESHOLD}%)" >&2
    echo "$(date) - ALERT: Disk usage is at ${USAGE}% (Threshold: ${THRESHOLD}%)" >> "$LOG_FILE"
    echo "Would you like to see the top 10 largest files in $DISK_PATH? (y/n)"
    read -r response
    if [[ "$response" == "y" ]]; then
        echo "Top 10 largest files in $DISK_PATH:"
        find "$DISK_PATH" -type f -exec du -h {} + / sort -rh / head -n 10
    fi
    echo "Would you like to clean up old log files? (y/n)"
    read -r cleanup_response
    if [[ "$cleanup_response" == "y" ]]; then
        echo "Compressing log files older than 7 days..."
        find "$LOG_FILE" -type f -name "*.log" -mtime +7 -exec gzip {} \;
        echo "Cleanup complete."
    fi
    exit 1
else
    echo "NORMAL: Disk usage is at ${USAGE}% (Threshold: ${THRESHOLD}%)"
    echo "$(date) - NORMAL: Disk usage is at ${USAGE}% (Threshold: ${THRESHOLD}%)" >> "$LOG_FILE"
    exit 0
fi




