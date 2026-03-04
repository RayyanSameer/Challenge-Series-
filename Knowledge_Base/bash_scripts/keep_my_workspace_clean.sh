#!/bin/bash
error_exit() {
    echo "$1" >&2
    exit "${2:-1}"
}

DEST_DIR="./backup/tmp_archive"

mapfile -t TMP_FILES < <(find . -maxdepth 1 -name "*.tmp" -type f)

[[ ${#TMP_FILES[@]} -eq 0 ]] && error_exit "No .tmp files found." 0

[[ ! -d "$DEST_DIR" ]] && mkdir -p "$DEST_DIR" || error_exit "Could not create archive dir" 1

mv "${TMP_FILES[@]}" "$DEST_DIR/" && echo "Moved ${#TMP_FILES[@]} file(s) to $DEST_DIR"