#Question 3: The Backup Rotation (Log Compression)

#Scenario:
#You need to manage disk space for a production app. You are tasked with creating a script, rotate_logs.sh, that compresses old log files.

#Requirements:

#    The script should look in a directory provided as the first argument ($1).

#   Identify all files ending in .log.

#   For each .log file found:
#       Create a compressed version using gzip.
#       The resulting file should be filename.log.gz.
#   After (and only after) successful compression, the original .log file must be removed.
#   If the directory provided doesn't exist, print an error to stderr and exit with status 1.

#Constraints:

#   You must use a for loop to process the files.

#   Do not use the rename command; do it manually within the loop.

#   Handle the case where no .log files exist in the directory without throwing a weird error.

#!/bin/bash

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}


if [ "$#" -ne 1 ]; then
    error_exit "Usage: $0 <directory>" 1
fi

DIR="$1"

if [ ! -d "$DIR" ]; then
    error_exit "Directory '$DIR' does not exist." 1
fi

shopt -s nullglob

LOG_FILES=("$DIR"/*.log)


if [ ${#LOG_FILES[@]} -eq 0 ]; then
    echo "No .log files found in $DIR."
    exit 0
fi


for file in "${LOG_FILES[@]}"; do
    if gzip "$file"; then
        echo "Compressed: $file"
    else
        error_exit "Failed to compress $file" 2
    fi
done