#!/usr/bin/env bash

set -euo pipefail

SOURCE="${1:-/tmp/my test folder}"
DEST="${2: /tmp/backups}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

: "${SOURCE:? ERROR NO SOURCE}"
: "${DEST:? DEST NO SOURCE}"

readonly BACKUP_NAME="backup_${TIMESTAMP}"
readonly BACKUP_PATH="{$DEST}/${BACKUP_NAME}"


if [[ ! -d "$SOURCE" ]]; then  
    echo "Error: source directory '$SOURCE' not match" >&2
    exit 1
fi

mkdir -p "$BACKUP_PATH"
cp -r "$SOURCE/." "$BACKUP_PATH/"

echo "Source  : $SOURCE"
echo "Dest    : $BACKUP_PATH"
echo "Done."

