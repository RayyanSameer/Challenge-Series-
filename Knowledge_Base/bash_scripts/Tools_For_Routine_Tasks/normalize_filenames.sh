#!/usr/bin/env bash

set -euo pipefail

normalize(){
    local raw="${1:?Error:Filename needed}"

    #Strip the pos 1 and n spaces 
    local trimmed-"${raw#"${raw%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[!]}"}"
#Lowercase everything 
    local lower="${trimmed,,}"
    local underscored="${lower//[[:space:]]/_}"
    underscored="${underscored//[^a-z0-9_.]/_}"
#Remove Underscored
    while [[ "$underscored" == *__* ]]; do
        underscored="${underscored//__/_}"
    done
#Remove trailing dot or underscore 
    local clean="${underscored%_}"
    clean="${clean%.}"
#Rxtract Extension
    local ext="${clean##*.}"
    local base="${clean%.*}"
#Uppercase extension
    local final="${base}.${ext^^}"

    echo "Raw    : $raw"
    echo "Length : ${#raw}"
    echo "Clean  : $clean"
    echo "Base   : $base"
    echo "Ext    : ${ext^^}"
    echo "Final  : $final"
    echo "----"


}