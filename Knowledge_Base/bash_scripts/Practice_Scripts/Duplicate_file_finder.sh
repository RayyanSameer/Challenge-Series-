#!/usr/bin/env bash
set -euo pipefail


DIR="${1:?Usage: $0 <directory>}"

# Declare an associative array (hash map)
declare -A seen


for file in "$DIR"/*; do
    
    if [[ -f "$file" ]]; then
        
        checksum=$(sha256sum "$file" | awk '{print $1}')
        if [[ -v seen["$checksum"] ]]; then
            echo "[DUPLICATE] '$file' is a duplicate of '${seen[$checksum]}'"
        else
            
            seen["$checksum"]="$file"
        fi
    fi
done