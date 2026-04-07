#WHAT : Scans a directory and logs the output to a file.
#HOW : Based on user input , while true loop is used to continuously scan the directory and log the output.
#WHY : To monitor changes in a directory and keep a record of the changes.

#!/bin/bash


error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

[[$ne 1]]n && error_exit "Usage: $0 <directory_path>"
DIR_PATH="$1"
LOG_FILE="directory_scan.log"

while true do:
    echo "Scanning"
    if [ -d "$DIR_PATH" ]; then
        echo "Directory: $DIR_PATH" >> "$LOG_FILE"
        ls -l "$DIR_PATH" >> "$LOG_FILE"
        echo "-----------------------------" >> "$LOG_FILE"
    else
        echo "Error: Directory $DIR_PATH does not exist." >&2
        exit 1
    fi
    sleep 10
done

#The script does this:
#1️ Takes a directory path as an argument
#2️ Enters an infinite loop
#3️ Scans the directory and logs the output to a file
#4️ Waits for 10 seconds before the next scan

