#!/bin/bash
#This script checks if a given disk is being full more than 80 percent and alerts you 

#Goal: Alert when the disk is nearly full.

#Rules: Take a percentage (e.g., 80) as $1. Check the usage of the root (/) partition. If it’s over the threshold, print a Red "CRITICAL" message. If not, print a Green "NORMAL" message.

#Psudocode 

#1. Get threshold percentage 
#2. Check partition details 
#3. If > 80 copmpare 
#4. Print red text else Green text 

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

#Gaurd code 
[[ $# -ne 1 ]] && error_exit "Usage: $0 argument"
THRESHOLD=$1
#Get threshold 

USAGE=$(df -P / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo -e "${RED}CRITICAL: Disk usage is at ${USAGE}% (Threshold: ${THRESHOLD}%)${NC}"
    exit 1
else
    echo -e "${GREEN}NORMAL: Disk usage is at ${USAGE}% (Threshold: ${THRESHOLD}%)${NC}"
    exit 0
fi
#The script does this:

#1️ Check disk usage of /
#2️ Extract percentage number
#3️ Compare with threshold argument
#4️ If usage ≥ threshold → alert + #exit 1
#5️ Otherwise → print normal + exit 0