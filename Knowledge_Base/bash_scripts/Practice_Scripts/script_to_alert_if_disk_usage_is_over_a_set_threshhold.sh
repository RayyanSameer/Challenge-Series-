#!/usr/bin/env bash
set -euo pipefail

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

#WHAT : This is a script to check if the a disk is under high usage 
#WHY : Helps keep an eye out for disks under highload , in the absence of an external utility manager 
#HOW : User sets a threshhold , utility manager checks 

#PSUDOCODE:
# Scan disks 
# List Disks 
# Set Thresholds for either one or all disks 
# if usage crosses , alert the admin 

echo "This is a simple script to get a birds eye view on your disk usage!"
#MENU

echo " Select Action : "
echo " [ 1 ] List all Disks "
echo " [ 2 ] Set universal usage threshold "
echo " [ 3 ] Set individual thresholds  "

# Goal for now : Minimal Functionality , check if usage crooses a threshold "

CHOICE=""
read -r -p "Selection: " CHOICE 
if [ "$CHOICE" == "1" ]; then
    lsblk
    
elif [ "$CHOICE" == "2" ]; then
        THRESHOLD=""
        read -r -p "Set Universal Threshold: [ Default is 80 ]: " THRESHOLD
        THRESHOLD="${THRESHOLD:-80}" # If empty, defaults to 80
        usage=$(df / | awk 'NR==2{print $5}' | tr -d '%')

        if [ "$usage" -gt "$THRESHOLD" ]; then
            echo " ALERT ! High Disk Usage "
            exit 1
            
        else 
            echo "Disk usage ($usage%) is below your threshold ($THRESHOLD%). All is well!"    
        fi
else
    echo "Invalid Option"
fi    
#TO ADD : File parser with disk names and their limits 

