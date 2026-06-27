#!/usr/bin/env bash
# D3: Filename normalizer

set -euo pipefail

normalize() {
    local raw="${1:?Error: filename needed}"

    # Strip leading whitespace
    local trimmed="${raw#"${raw%%[![:space:]]*}"}"
    # Strip trailing whitespace
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

    # Lowercase
    local lower="${trimmed,,}"

    # Replace spaces with underscores
    local underscored="${lower//[[:space:]]/_}"
    # Replace non-alphanumeric (except dots) with underscores
    underscored="${underscored//[^a-z0-9_.]/_}"

    # Collapse double underscores
    while [[ "$underscored" == *__* ]]; do
        underscored="${underscored//__/_}"
    done

    # Strip trailing underscore or dot
    local clean="${underscored%_}"
    clean="${clean%.}"

    # Extract extension and base
    local ext="${clean##*.}"
    local base="${clean%.*}"

    # Final with uppercase extension
    local final="${base}.${ext^^}"

    echo "Raw      : $raw"
    echo "Length   : ${#raw}"
    echo "Clean    : $clean"
    echo "Base     : $base"
    echo "Ext      : ${ext^^}"
    echo "Final    : $final"
    echo "---"
}

normalize "  My REPORT file (FINAL) v2.docx  "
normalize "server LOG 2026.LOG"
normalize "photo   summer   holiday.JPG"