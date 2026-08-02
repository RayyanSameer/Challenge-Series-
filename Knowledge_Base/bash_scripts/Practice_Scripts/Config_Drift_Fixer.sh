#!/usr/bin/env bash

set -euo pipefail

error_exit(){
    echo "$1" >&2
    exit "${2:-1}" 
}

#WHAT : config drift catcher 

secure_baseline=""

target_file=""

read -r -p "Path to your source of truth file :" secure_baseline

if [[ -z "$secure_baseline" ]]; then
    error_exit "You did'nt enter anything"
fi

if [[ ! -f "$secure_baseline" ]]; then
        error_exit "File Does not exist , check path"
fi

if [[ -w "$secure_baseline" ]]; then
    while true; do
        read -r -p "Baseline file is writable. Make read-only (chmod 444)? (y/n): " yn
        case "${yn,,}" in
            y|yes)
                echo "Locking down baseline permissions..."
                chmod 444 "$secure_baseline"
                break  # Exit the loop and continue script
                ;;
            n|no)
                error_exit "Aborted: Baseline file must be protected before proceeding."
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
fi

read -r -p "Enter your target config file : " target_file
if diff -q "$secure_baseline" "$target_file" > /dev/null; then
    echo "Files are identical. , No config drift "
else
    echo "WARNING: Files differ! Config drift detected. Please manually review changes."
fi

