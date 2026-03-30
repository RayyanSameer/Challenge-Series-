#Checks Ping to Server 

#!/bin/bash
PATH_TO_CSV=""
CHOICE=""
IP=""
OUTPUT_CSV="ping_results.csv"

echo "Welcome to ping check"
read -p "Enter [1] for a list of  server or [2] specifc one " CHOICE


if [ "$CHOICE" == "1" ]; then read -p " List path to csv file holding the ip's PATH TO CSV" PATH_TO_CSV

    if [[ -f "$PATH_TO_CSV" ]]; then
    echo "Host,IP,Status" > "$OUTPUT_CSV"
    tail -n +2 "$PATH_TO_CSV" | while IFS=, read -r host ip
        do
            ip=$(echo "$ip" | tr -d '\r')

            if ping -c 2 -W 2 "$ip" > /dev/null 2>&1; then
                status="UP"
            else
                status="DOWN"
    fi
    
    
        echo "$host,$ip,$status"
        echo "$host,$ip,$status" >> "$OUTPUT_CSV"
    done

elif [ "$CHOICE" == "2" ]; then   
    read -p "Enter IP: " IP
   
    if ping -c 2 -W 2 "$IP" > /dev/null 2>&1; then
                status="UP $IP is up"
            else
                status="$IP is DOWN"
    fi
    echo "Host $IP is $status"
fi    






