#!/bin/bash

#WHAT : A Script to autorun all scripts in this repo with shellcheck and return if anything needs to be fixed

set -euo pipefail

REPORT_FILE="shellcheck_report.txt"

run_shellcheck() {
    local target_dir 
    read -r -p "Enter the target dir (Press . for this dir )" target_dir
    target_dir="${target_dir:-.}"
    if [[ ! -d "$target_dir" ]]; then
        echo "Error: Directory '$target_dir' does not exist." >&2
        return 1
    fi

    echo "Running ShellCheck on scripts in '$target_dir'..."

    if find "$target_dir" -type f -name "*.sh" -exec shellcheck {} + | tee "$REPORT_FILE"; then
        if [[ -s "$REPORT_FILE" ]]; then
            echo -e "\n[!] Issues found! Detailed report saved to: $REPORT_FILE"
        else
            echo -e "\n[OK] All scripts passed ShellCheck cleanly."
        fi
    fi
}
while true; do
    read -r -p "Press 'Q' to quit, or any other key to run ShellCheck: " choice
    case "$choice" in
        [Qq]*)
            echo "Exiting."
            exit 0
            ;;
        *)
            run_shellcheck
            echo -e "\n--------------------------------------------------"
            ;;
    esac
done


