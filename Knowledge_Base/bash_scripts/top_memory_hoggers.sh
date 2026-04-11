#!/bin/bash
# "Top Offender"

#    The Goal: Find the top 5 processes consuming the most RAM and write them to a file. If any process uses > 50% of total RAM, send a "CRITICAL" alert to the terminal.

#    Key Commands: ps aux --sort=-%mem, head, if/then logic.

#    Why: Troubleshooting "OOM Killer" (Out of Memory) events.

#Check RAM Usage my pid 
#List Top 5 
#Also list Name , User , PID , is_critical()
#Log into a file
#If any process eats > 50 RAM , log into a file mem_hog.log
#Trigger an alert 

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

PATH_TO_LOG_FILE=""

echo "Welocome to the Top Hoggers Utility! "
 


ps -eo rss,pid,user,command | sort -rnk 1 | head -5 | awk '{ hr[1024**2]="GB"; hr[1024]="MB"; for (x=1024**3; x>=1024; x/=1024) { if ($1>=x) { printf ("%-6.2f %s ", $1/x, hr[x]); break } } } { printf ("%-6s %-10s ", $2, $3) } { for ( x=4 ; x<=NF ; x++ ) { printf ("%s ",$x) } print ("\\n") }' | cat > "$PATH_TO_LOG_FILE"



