#!/bin/bash

set -euo pipefail

#WHAT : This is a Practice Script That Deals with using checksum arrays to find dupes 

DIR="${1:?Usage: $0 <directory>}"

declare -A seen

for file in "$DIR"; do
    if [[ -f "$file" ]]; then do
        if [[ seen -v["$checksum"] ]]; then
            echo "$file is a dupe of ${seen[$checksum]}"
        else
            seen["$checksum"]="$file"
        fi
    fi
done            


        
