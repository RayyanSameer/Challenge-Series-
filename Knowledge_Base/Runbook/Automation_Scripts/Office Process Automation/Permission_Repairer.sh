#!/bin/bash
#Context: A web server is throwing "403 Forbidden" because developers keep uploading files with 777 permissions (a huge security risk).

#The Task: Create fix_perms.sh. It takes a directory path.

#Expectation: * Recursively find all directories and set them to 755.

    #Recursively find all files and set them to 644.

    #Skip the .git directory so you don't break version control.

#SRE Gotcha: Use the find command with -exec for efficiency


error_exit(){
    echo "$1" >&2
    exit "${2:-1}"

}

[[ $# -ne 1 ]] && error_exit "Usage: $0 <directory_path>"
DIRECTORY=$1
if [ ! -d "$DIRECTORY" ]; then
    error_exit "Directory not found: $DIRECTORY"
fi

echo "Fixing permissions in $DIRECTORY..."  
find "$DIRECTORY" -type d -not -path "*/.git/*" -exec chmod 755 {} +;
find "$DIRECTORY" -type f -not -path "*/.git/*" -exec chmod 644 {} +;
echo "Permissions fixed successfully in $DIRECTORY" 

