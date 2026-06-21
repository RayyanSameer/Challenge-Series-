#!/usr/bin/env bash

set -euo pipefail
#Backup to dir 

SOURCE="${1:-/tmp/my test folder}"
DEST="${2:-/tmp/backups}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

#Errors 

: "${SOURCE:?Error: SOURCE is needed}"
: "${DEST:?Error: DEST is needed}"

readonly BACKUP_NAME="Backup_${TIMESTAMP}"
readonly BACKUP_PATH="${DEST}/${BACKUP_NAME}"

#Locks down the final destination path variables.

if [[ ! -d "$SOURCE" ]]; then
    echo "Error: source directory '$SOURCE' does not exist" >&2
    exit 1
fi

mkdir -p "$BACKUP_PATH"
cp -r "$SOURCE/." "$BACKUP_PATH/"

echo "Source  : $SOURCE"
echo "Dest    : $BACKUP_PATH"
echo "Done."

