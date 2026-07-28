#!/bin/bash

# WHAT : A script to check if individual URLs or a list of URLs are live.
# WHY  : In an environment with multiple online resources, this helps quickly check uptime.
# HOW  : Uses 'curl' to send a HEAD request and check for a valid HTTP response code.

set -euo pipefail

error_exit(){
    echo "Error: $1" >&2
    exit "${2:-1}"
}

check_url_status(){
    local target_url="$1"
    echo -n "Checking $target_url... "
    
    if http_code=$(curl -s -o /dev/null -I -w "%{http_code}" --connect-timeout 3 "$target_url"); then
        
        if [[ "$http_code" -ge 200 && "$http_code" -lt 400 ]]; then
            echo "[ LIVE ] (HTTP $http_code)"
        else
            echo "[ DOWN ] (HTTP $http_code)"
        fi
    else
        echo "[ UNREACHABLE "
    fi
}

# Menu 
echo "============================================="
echo " Press [1] to check a specific URL."
echo " Press [2] to load a list of URLs from a file."
echo "============================================="
read  -r -p "Enter your choice: " choice

if [[ "$choice" == "1" ]]; then
    read -r -p "Enter URL of the site you want to check: " url
    if [[ -z "$url" ]]; then
        error_exit "Input cannot be empty"
    fi
    check_url_status "$url"

elif [[ "$choice" == "2" ]]; then
    read -r -p "Enter path to textfile containing the list of URLs: " filepath
    if [[ -z "$filepath" ]]; then
        error_exit "Path cannot be empty"
    elif [ ! -f "$filepath" ]; then
        error_exit "File does not exist. Please check the path."
    fi
    
    
    readonly URL_REGEX='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
    
    echo "---------------------------------------------"
    
    while IFS= read -r url || [[ -n "$url" ]]; do
       
        url=$(echo "$url" | xargs)
        
        
        [[ -z "$url" || "$url" == \#* ]] && continue
        
        if [[ "$url" =~ $URL_REGEX ]]; then
            check_url_status "$url"
        else
            echo "$url : [ INVALID FORMAT ]"
        fi
    done < "$filepath"

else
    error_exit "Invalid menu choice."
fi