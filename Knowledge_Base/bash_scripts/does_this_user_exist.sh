#This checks if a user exists 

#Goal: Verify if a system user exists.

#Rules: Take a username as $1. Check the /etc/passwd file. If they exist, print their UID and their primary group. If not, exit with an error.


#Psudocode:
# 1. Take Username 
# 2. check etc/password
# 3. Validate existence 
# 4. Store the attributes in speciaized variables 



#!/bin/bash

error_exit(){
    "echo $1" >&2
    "exit {2:-1}"
}
[[ $# -lt 1 ]] && error_exit "Usage: $0 arguement"


USERNAME=$1

if id "$USERNAME" >/dev/null 2>&1; then
    echo "-- USer Found --"

    USER_iD=$(id -u "$USERNAME")
    GROUP_ID=$(id -g "$USERNAME")     
    HOME_DIR=$(grep "^$USERNAME:" /etc/passwd | cut -d: -f6)""

    echo "UID:        $USER_ID"
    echo "Primary GID: $GROUP_ID"
    echo "Home Folder: $HOME_DIR"
else
    error_exit "Error: User '$USERNAME' does not exist on this system." 1
fi