#!/bin/bash

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

[[ $# -ne 1 ]] && error_exit "Usage: $0 <directory_path>"
DIRECTORY=$1
if [ ! -d "$DIRECTORY" ]; then
    error_exit "Directory not found: $DIRECTORY"
fi

find "$DIRECTORY" -type -d -not -path "*/.git/*" -exec chmod 755 {} +;
find "$DIRECTORY" -type f -not -path "*/.git/*" -exec chmod 644 {} +;
echo "Permissions fixed successfully in $DIRECTORY"