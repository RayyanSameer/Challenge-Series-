#Cleans logs without deleting the file

#Checks if the file /tmp/app.log exists.

#If it exists, it should clear the contents of the file without deleting the file itself (the application process holds a file handle and will crash if the file is removed).

#If the file does not exist, the script should print an error message to standard error (stderr) and exit with a non-zero status code.

#If successful, it should print "Logs cleared." to standard output (stdout).


#!/bin/bash

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

FILE_PATH="/tmp/app.log"
if [ ! -f "$FILE_PATH" ]; then
   error_exit "Error: $FILE_PATH not found." 2
elif [ ! -w "$FILE_PATH" ]; then
    error_exit "Error not writeable." 1
fi 

if : > "$FILE_PATH"; then
    echo "Success: Logs cleared." >&1
else
    error_exit "Error: Failed to clear logs in $FILE_PATH." 1
fi


