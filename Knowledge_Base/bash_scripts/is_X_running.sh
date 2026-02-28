#Question 4: The Process Sentinel (Monitoring)

#Scenario:
#You have a critical service (e.g., nginx). If it goes down, the company loses money. You need a script, monitor_service.sh, that checks if a process is running.

#Requirements:

#    The script takes a process name as an argument (e.g., ./monitor_service.sh nginx).

#   Check if any process with that name is currently running.

#   If it is running:

#       Print "Service [name] is healthy." and exit with code 0.

#   If it is not running:

#       Print "CRITICAL: Service [name] is down!" to stderr.

#       Attempt to "restart" it (for this task, just print "Attempting restart..." to stdout).

#       Exit with code 2.

#Constraints:

#   Do not use systemctl or service commands.

#   Use pgrep or a combination of ps and grep to find the process.

#   Warning: If you use ps | grep, make sure your script doesn't accidentally find its own grep process in the list (a very common "junior" mistake).


#!/bin/bash
error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}
if [ "$#" -ne 1 ]; then
    error_exit "Usage: $0 <process_name>" 1
fi

PROCESS="$1"

if pgrep -x "$PROCESS" > /dev/null; then
    echo "Service $PROCESS is healthy."
    exit 0
else
   echo "CRITICAL: Service [name] is down!" >&2
   echo "Attempting to restart"
   exit 2
fi