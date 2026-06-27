#!/usr/bin/env bash
set -euo pipefail
normalize(){
    local raw="${1:?Error: FIle needed}"
    local trimmed="${raw#"${raw%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

    local lower="$trimmed,,"
    local underscored="${trimmed// /_}"
    underscored="$underscored//[^a-z0-9_.]/_}"

    while [[ "$underscored" == *__*]]; do
        underscored="${underscored//__/_}"
    done

    local clean="${underdscored%_}"
    clean="${clean%.}"

    local ext="${clean##*.}"
    local base="${clean%.*}"

    # Uppercase the extension
    local final="${base}.${ext^^}"
    echo "Raw      : $raw"
    echo "Length   : ${#raw}"
    echo "Clean    : $clean"
    echo "Base     : $base"
    echo "Ext      : ${ext^^}"
    echo "Final    : $final"
    echo "---"

} 