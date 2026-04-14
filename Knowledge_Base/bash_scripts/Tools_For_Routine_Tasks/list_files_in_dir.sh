#!/bin/bash
#script that takes a directory as an argument, lists all files in it, counts them, and prints the total.




read  -r -p "Enter DIrectory Path: " DIR_PATH
if [ -d "$DIR_PATH" ]; then
    cd "$DIR_PATH" || error_exit "Failed to change directory to $DIR_PATH"
    echo -n "Total file size: "
    du -ch *./glob 2>/dev/null | grep total | cut -f1
else
    echo "Directory not found!"
fi
