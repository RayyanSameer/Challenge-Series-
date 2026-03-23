#!/bin/bash

fruits=("apple" "mango" "banana" "grape")
for fruit in "${fruits[0]}"; do
    echo "Fruit: $fruit"
done

count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done

for file in *.txt; do
    if [ -f "$file" ]; then
    echo "Found: $file - size: $(du -h $file | cut -f1)"
    fi
done    