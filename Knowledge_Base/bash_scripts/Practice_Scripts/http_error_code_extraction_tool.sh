#!/usr/bin/env bash

#WHAT : This is a bespoke tool to extract HTTPS error codes and group them with a counter , similar to the docker error extractor i made a while back 
#WHY : Instantly scoop out error codes with locations , groups and guides the user to faster resolution 
#HOW : uses grep -oP to extract error codes , sort | uniq -c | sort -rn

set -euo pipefall

LOGFILE="${1:?Usage:$0 <nginx_error_log>}"
read -p -r "Enter path to your logfile: " LOGFILE

#extract
#grep -oP to pull error codes 

echo "COUNT CODE"
grep -oE '" [45][0-9]{2} ' "$LOGFILE" | grep -oE '[45][0-9]{2}' | sort | uniq -c | sort -rn

