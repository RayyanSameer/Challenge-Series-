#a script that takes a source directory and a backup destination. It finds files modified in the last 24 hours and bundles them into a dated .tar.gz archive

#!/bin/bash

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}



#Santize

[[ $# -ne 2 ]] && error_exit "Usage: $0 <source_dir> <backup_dest>" 1

SOURCE_DIR="$1"
BACKUP_DEST="$2"
DATE=$(date +%Y-%m-%d)
FINAL_DEST="$BACKUP_DEST/backup_$DATE.tar.gz"

[[ ! -d "$SOURCE_DIR" ]] && error_exit "Source directory $SOURCE_DIR not found." 1
[[ ! -d "$BACKUP_DEST" ]] && error_exit "Backup destination $BACKUP_DEST not found." 1

FILE_LIST=$(mktemp)
find "$SOURCE_DIR" -type f -mtime -1 > "$FILE_LIST"

if [[ ! -s "$FILE_LIST" ]]; then
    echo "No files modified in the last 24 hours. Skipping backup."
    rm "$FILE_LIST"
    exit 0

echo "Backing up $(wc -l < "$FILE_LIST") files..."
tar -czf "$FINAL_FILE" -T "$FILE_LIST"

if [[ -f "$FINAL_FILE" ]]; then
    SIZE=$(du -h "$FINAL_FILE" | awk '{print $1}')
    echo "Backup successful: $FINAL_FILE ($SIZE)"
else
    error_exit "Backup failed!" 2
fi


rm "$FILE_LIST"    