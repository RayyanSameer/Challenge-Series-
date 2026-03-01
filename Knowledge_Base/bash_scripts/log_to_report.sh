#!/bin/bash
# Description: This is the script you use when a developer says, "The app is slow, find out why," and hands you a 2GB file of text.

error_exit() {
    echo "$1" >&2
    exit "${2:-1}"
}

#Sanitize 

if [[ -z "$1" ]]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

LOG_FILE="$1"

if [[ ! -r "$LOG_FILE" ]]; then
    echo "Error: Cannot read $LOG_FILE"
    exit 1
fi

echo "--- Log Report for $LOG_FILE ---"]]

ERRORS=$(grep -c "\[ERROR\]" "$LOG_FILE")
WARNS=$(grep -c "\[WARNING\]" "$LOG_FILE")
INFOS=$(grep -c "\[INFO\]" "$LOG_FILE")

if [ $ERRORS -gt 10 ];then
    echo -e "\e[31mCRITICAL: High error volume detected!\e[0m"
fi    

echo "Total Errors:   $ERRORS"
echo "Total Warnings: $WARNS"
echo "Total Infos:    $INFOS"
echo "-------------------------------"

echo "Top 3 Error Messages:"

grep "\[ERROR\]" "$LOG_FILE" | awk -F' ' '{for(i=4;i<=NF;i++) printf $i" "; print ""}' | sort | uniq -c | sort -nr | head -3