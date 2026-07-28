#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ge 2 ]]; then
    input_file="$1"
    words_to_be_excluded_file="$2"
else
    read -r -p "Enter input file path: " input_file
    read -r -p "Enter excluded words file path: " words_to_be_excluded_file
fi

if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' not found." >&2
    exit 1
fi

if [[ ! -f "$words_to_be_excluded_file" ]]; then
    echo "Error: Excluded words file '$words_to_be_excluded_file' not found." >&2
    exit 1
fi




tr '[:upper:]' '[:lower:]' < "$input_file" |
tr -d '.,!?;:"' |
tr ' ' '\n' |
grep -v -w -f  "$words_to_be_excluded_file" |
sort |
uniq -c |
sort -rn |
head -20
