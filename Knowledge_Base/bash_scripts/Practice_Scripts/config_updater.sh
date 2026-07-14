#!/usr/bin/env bash
set -euo pipefail

CONF="${1:?Usage: $0 <file.conf> <key> <value>}"
KEY="${2:?}"
VALUE="${3:?}"

cp "$CONF" "$CONF.bak"

if grep -q "^${KEY}=" "$CONF"; then
    sed -i "s/^${KEY}=.*/${KEY}=${VALUE}/" "$CONF"
else
    echo "${KEY}=${VALUE}" >> "$CONF"
fi