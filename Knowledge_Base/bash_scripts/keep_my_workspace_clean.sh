#This bash script keeps my workspace clean 

#Goal: Move specific files to a "Trash" folder.

#Rules: Find all files in the current directory ending in .tmp. If found, move them to a directory named backup/tmp_archive/. If the archive folder doesn't exist, create it first.

#Psudocode
# 1. locate all .tmp files in current workspace 
# 2. Check if backup folder exists 
# 3. move to backup archive 

#!/bin/bash

error_exit(){
    "error $2 " >&2
    "exit{2:-1}"

}

if [[ $# -ne 1 ]]; then
    error_exit "Usage: $0 <process_name>" 1
fi

DEST_DIR="./backup/tmp_archive"
#finding all tmp files over here

#check if the backup folder exists and if not make one 
if [[ ! -d "$DEST_DIR" ]]; then
    echo "Creating archive directory..."
    mkdir -p "$DEST_DIR" || error_exit "Could not create directory" 1
fi

