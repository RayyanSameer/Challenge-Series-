#!/usr/bin/env bash 

#WHAT : This is a simple memory aggregator 

echo "user       rss(MB) vmem(MB)"
for user in $(users | tr ' ' '\n' | sort -u); do
    ps -U $user --no-headers -o rss,vsz \
        | awk -v user="$user" '{rss+=$1; vmem+=$3} END{printf("%-10s %8.1f %8.1f\n", user, rss/1024, vmem/1024)}'
done | sort --general-numeric-sort --key=3 --reverse   