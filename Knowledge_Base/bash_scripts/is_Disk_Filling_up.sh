#Question 5: The Disk Space Alert (Arithmetic & Logic)

#Scenario:
#A common DevOps task is monitoring disk usage. You need to write a script, disk_alert.sh, that warns you when a partition is getting full.

#Requirements:

    #The script takes a threshold percentage as its only argument (e.g., 80 for 80%).

    #Check the disk usage of the root partition (/).

    #If the usage percentage is greater than or equal to the threshold:

        #Print "ALERT: Disk usage is at [X]%" to stderr.

        #Exit with status 1.

    #If the usage is below the threshold:

        #Print "Disk usage is normal: [X]%" to stdout.

        #Exit with status 0.

#Constraints:

    #Use the df command to get the usage.

    #You will need to use grep, awk, or sed to strip the % sign from the output so you can compare it as a number.

    #Use Bash arithmetic comparison (e.g., -ge or (( ... ))).

#!bin/bash   

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

theshold="$1"
if [ -z "$1" ]; then error_exit "Usage..." 1;
fi

USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

if [ "$USAGE" -ge "$1" ]; then
   echo "ALERT: Disk is at ${USAGE}%" >&2
   exit 1
else
    echo "Normal: Disk is at ${USAGE}%"
    exit 0
 fi