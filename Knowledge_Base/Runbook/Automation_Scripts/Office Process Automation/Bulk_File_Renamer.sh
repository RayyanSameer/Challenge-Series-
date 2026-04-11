#!/bin/bash

set -euo pipefail

# Config 
DRY_RUN=false
LOG_FILE="rename_log.txt"
DIRECTORY=""
PATTERN=""
REPLACEMENT_PATTERN=""

# Functions
log(){
    local level="$1"
    local message="$2"
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [$level] $message" | tee -a "$LOG_FILE"
}

error_exit(){
    log "ERROR" "$1"
    echo "Usage: $0 [-d|--dry-run] <directory> <pattern> <replacement_pattern>"
    exit "${2:-1}"
}

# Parse arguments
if [[ "${1:-}" == "-d" || "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    shift
fi

if [[ $# -ne 3 ]]; then
    error_exit "Invalid number of arguments."
fi

DIRECTORY="$1"
PATTERN="$2"
REPLACEMENT_PATTERN="$3"

# Validations
[[ ! -d "$DIRECTORY" ]] && error_exit "Directory not found: $DIRECTORY"
[[ ! -w "$DIRECTORY" ]] && error_exit "Cant write here !: $DIRECTORY"

log "INFO" "Starting bulk file renaming in $DIRECTORY"

# Main Loop
for file_path in "$DIRECTORY"/*; do
    [[ -d "$file_path" ]] && continue
    
    filename=$(basename "$file_path")
    
    # Regex matching
    if [[ "$filename" =~ $PATTERN ]]; then
        
        
        new_name="$REPLACEMENT_PATTERN"
        
        # Loop through capturing groups to replace \1, \2, etc.
        for i in $(seq 1 $((${#BASH_REMATCH[@]} - 1))); do
            new_name="${new_name//\\$i/${BASH_REMATCH[$i]}}"
        done
        
        target_path="$DIRECTORY/$new_name"
        
   
        if [[ -e "$target_path" && "$filename" != "$new_name" ]]; then
            log "WARN" "Skipping '$filename' -> '$new_name' (Target already exists)"
            continue
        fi


        if [ "$DRY_RUN" = true ]; then
            echo "[DRY-RUN] Would rename: '$filename' -> '$new_name'"
        else
            mv "$file_path" "$target_path"
            log "SUCCESS" "Renamed: '$filename' -> '$new_name'"
        fi
    fi
done

log "INFO" "Operation completed."