#Question 6: The Log Cleaner (Advanced Loops)

#Scenario:
#You have a directory /var/log/app/. Inside, there are hundreds of files like access.log, error.log, debug.tmp, and old.bak. You need to create a cleanup script.

#Requirements:

    #The script takes a directory path as the first argument ($1).

    #Validate that the argument is a directory.

    #Validate that the user has write permissions to that directory.

    #Loop through every file in that directory:

        #If the file ends in .tmp or .bak, delete it.

        #If the file ends in .log and is older than 7 days, compress it (gzip).

    #Print a summary at the end: "Deleted X files, Compressed Y files."

#Constraints:

    #Use find to identify the old log files.

    #Use a case statement or if/elif inside the loop to handle the different extensions.

#The Pro Tip:
#To find files older than 7 days, use find "$DIR" -name "*.log" -mtime +7.

#!/bin/bash

#Standard error module 

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

#Check if arguement is a dir 

[[ -z "$DIR" ]] && error_exit "Usage $0 <dir>" 1
DIR="$1"
[[ ! -d "$DIR" ]] && error_exit "Error not a dir" 1
[[ ! -w "$DIR "]] && error_exit "Error can't write here " 1

#Count

DELETED=0
COMPRESSED=0

for file in "$DIR"/*.tmp "$DIR"/*.bak; do
    if [[ -f "$file" ]]; then
        rm "$file" && ((DELETED++))
    fi
done

while IFS= read -r file; do
    if [[ -f "$file" ]]; then
        gzip "$file" && ((COMPRESSED++))
    fi
done < <(find "$DIR" -name "*.log" -type f -mtime +7)

Final Report
echo "Summary: Deleted $DELETED files, Compressed $COMPRESSED files."