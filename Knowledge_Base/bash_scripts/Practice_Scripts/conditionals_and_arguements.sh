#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./check.sh <number>"
    exit 1
fi

if [ "$1" -gt 10 ]; then
    echo "$1 is geater than 10"
elif [ "$1" -eq 10 ]; then    
    echo "Exacctly 10"
else
    echo "less than 10"   
fi     