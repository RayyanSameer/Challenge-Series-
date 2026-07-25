#!/usr/bin/env bash
set -euo pipefail


target_dir="${1:?Usage: $0 <directory>}"

if [[ ! -d "$target_dir" ]]; then
    echo "Error: '$target_dir' is not a directory" >&2
    exit 1
fi

mapfile -d '' files < <(find "$target_dir" -type f -atime +7 -name "*.tmp" -print0)

if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .tmp files accessed more than 7 days ago were found in '$target_dir'."
    exit 0
fi

echo "Found ${#files[@]} file(s) to delete:"
printf '%s\n' "${files[@]}"
echo "----------------------------------------"

read -rp "Press Y to confirm deletion, or any other key to abort: " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    
    printf '%s\0' "${files[@]}" | xargs -0 rm -v
    echo "Deletion completed successfully."
else
    echo "Aborted. No files were deleted."
    exit 0
fi