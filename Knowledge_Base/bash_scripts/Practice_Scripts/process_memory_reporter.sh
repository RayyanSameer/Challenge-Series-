#!/usr/bin/env bash
set -euo pipefail

THRESHOLD="{$1:-1.0}"

ps aux | awk -v thresh="$THRESHOLD" '
    NR > 1 && $4 > thresh {
    printf "PID: %-8s USER: %-10s MEM: %-6s CMD: %s\n", $2, $1, $4, $11
    total += $4
    }
    END{
        print "Total memory used by these processes: " total "%"

    }
'
    
    

