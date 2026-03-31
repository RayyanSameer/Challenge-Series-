#SSL Certificate Expiry Checker

#    The Goal: Use openssl to check the expiry date of a domain’s SSL certificate and print how many days are left.

#    Key Commands: openssl s_client, date -d, bc (for math).

#    Why: Prevents the "Website is Not Secure" error that kills business value.

# 1. Capture the URL from user input
# 2. Use openssl s_client to connect to port 443
# 3. Pipe that output to 'openssl x509' to extract the 'enddate'
# 4. Use the 'date' command to normalize that string into seconds
# 5. Perform the math using 'bc' (Binary Calculator)
# 6. Output the result and append a timestamped entry

#!/bin/bash

error_exit() {
    echo "$1" >&2
    exit "${2:-1}"
}

OUTPUT_LOG="$HOME/ssl_expiry.log"
CHOICE=""

echo "Welcome to SSL Checker!"
echo "Press [1] to check a specific site"
echo "Press [2] to check a list of sites from CSV"

read -p "Enter choice: " CHOICE

#Here comes the menu 

if [ "$CHOICE" == "1" ]; then
    read -p "Enter hostname: " HOSTNAME

    EXPIRY=$(echo | openssl s_client -servername "$HOSTNAME" -connect "$HOSTNAME":443 2>/dev/null \
        | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -z "$EXPIRY" ]; then
        error_exit "Could not get certificate"
    fi

    EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
    NOW_EPOCH=$(date +%s)
    DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ) )

    echo "$HOSTNAME expires in $DAYS_LEFT days ($EXPIRY)" | tee -a "$OUTPUT_LOG"

elif [ "$CHOICE" == "2" ]; then
    read -p "Enter path to CSV" PATH_TO_CSV

    if [[ ! -f "$PATH_TO_CSV" ]]; then
        error_exit "File not found : $PATH_TO_CSV"
    fi

    echo "Host, ExpityDate,DaysLeft"  > "$OUTPUT_LOG"
    tail -n +2 "$PATH_TO_CSV" | while IFS=, read -r host ip; do
        ip=$(echo "$ip" | tr -d '\r')

        EXPIRY=$(echo | openssl s_client -servername "$host" -connect "$ip":443 2>/dev/null \
            | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -z "$EXPIRY" ]; then
        echo "$host,UNREACHABLE,N/A" | tee -a "$OUTPUT_LOG"
        continue
    fi

    EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
    NOW_EPOCH=$(date +%s )
    DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400))

    echo "$host,$EXPIRY,$DAYS_LEFT days" | tee -a "$OUTPUT_LOG"
    done

    echo "Results saved to $OUTPUT_LOG"
else
    error_exit "Invalid choice. Enter 1 or 2."
fi

#







