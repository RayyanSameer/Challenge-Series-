#This script checks if a given disk is being full more than 80 percent and alerts you 

#Goal: Alert when the disk is nearly full.

#Rules: Take a percentage (e.g., 80) as $1. Check the usage of the root (/) partition. If it’s over the threshold, print a Red "CRITICAL" message. If not, print a Green "NORMAL" message.

#Psudocode 

#1. Get threshold percentage 
#2. Check partition details 
#3. If > 80 copmpare 
#4. Print red text else Green text 

#!/bin/bash
error_exit(){
    "echo $1" >&2
    "exit {2:-1}"
}

#Gaurd code 

[[ ! $# ne=1 ]] && error_exit "Usage: $0 arguement"

THRESHOLD = $1
#Get threshold 


$USAGE=(df -P/ | tail -1 | awk '{print $5}' | tr -d '%' ) 

if [ '$USAGE' -ge "$1" ]; then
    echo "ALERT: Disk is at ${USAGE}%" >&2
exit 1
echo "Normal: Disk is at ${USAGE}%"
exit 0