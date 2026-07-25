#!/bin/bash
#finds the largest log files in a given directory , helps if you have multiple crashlogs from the same app , each of which are progressive/

set -euo pipefail 

error_exit(){
    echo "$1"
    exit "${2:-1}"
}
search_dir="${1:-.}"
if [[ ! -d "$search_dir" ]]; then
    error_exit "Directory '$search_dir' does not exist"
fi
find "$search_dir" -type f -iname "*.log" -print0 |  xargs -0 -I{} wc -l {} |   sort -rn  |
head -5