#This bash script essentially locks down a given directory to anyone but it's owner 

#Goal: Fix permissions on a directory.

#Rules: Take a directory path as $1. Ensure the script only runs if the directory exists. Change all files inside to be "Read/Write" for the owner only (600) and all subdirectories to be "Full Access" for the owner only (700).

#Psudocode 
# 1. take target directory
# 2. Validate the existence of that diectory
# 3. change permissions of ALL subfiles to r/w only for the owner 
# 4. have subdir as full access 

#!/bin/bash
error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

[[ $# -lt 1 ]] && error_exit "Usage: $0 arguement"

#Take directory input 
DIR=$1

#Validate the existence of that directory

[[ ! -d $DIR ]] && error_exit"That directory does not exist"

#For dirs 
find "$DIR" -type d -exec chmod 700 
{} +

find "$DIR" -type f -exec chmod 600 {} +

echo "Permissions secured!"