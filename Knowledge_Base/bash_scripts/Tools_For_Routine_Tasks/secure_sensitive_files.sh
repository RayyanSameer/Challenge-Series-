#!/bin/bash

# Function to handle errors and exit
error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

#Guard code: Ensure an argument is provided
[[ $# -lt 1 ]] && error_exit "Usage: $0 <directory_path>"


DIR="$1"

[[ ! -d "$DIR" ]] && error_exit "Error: Directory '$DIR' does not exist."


find "$DIR" -type d -exec chmod 700 {} +


find "$DIR" -type f -exec chmod 600 {} +

echo "Permissions secured! Owner now has exclusive access to '$DIR'."