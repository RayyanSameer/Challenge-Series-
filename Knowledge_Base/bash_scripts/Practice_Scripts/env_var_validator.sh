#!/bin/bash
set -euo pipefail
#WHAT : This script basically acts as a validator against env vars 
#WHY : Catch an error before it hits prod , enforce data type , security and compliance

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"

}

Required_vars=("DATABASE_URL" "API_KEY" "SECRET_KEY")
missing=()

for var in "${Required_vars[@]}"; do
    if [ -z "${!var:-}" ]; then
        missing+=("$var")
    fi
done

if [ ${#missing[@]} -ne 0 ]; then
    echo "Error: The following required environment variables are missing:" >&2
    for var in "${missing[@]}"; do
        echo "- $var" >&2
    done
    exit 1
fi

echo "Done"

