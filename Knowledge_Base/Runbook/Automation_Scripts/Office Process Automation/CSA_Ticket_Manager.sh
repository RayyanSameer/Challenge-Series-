#!/bin/bash
#WHAT : A Bash Script that reads tickets based on the keywords (Like : Resolved, Closed, Open) and then automatically logs the details in a CSV file for record-keeping and analysis.

#GOAL : To automate the process of tracking and managing tickets, making it easier to analyze trends and performance over time.



#Note to sel: always check if the file exists before trying to read it. If not, create it with headers.


#PSUDOCODE
#1. Read keywords from the file
#2. For each keyword, search the ticket system (simulate with echo for now)
#3. Extract relevant details (simulate with random data)
#4. Append details to the CSV log file


LOG_FILE=$1
KEYWORDS_FILE=$2
OUTPUT_CSV="ticket_log.csv"

error_exit(){
    echo $1 >&2
    exit "${2:-1}"
}

[[ $ne 2 ]] && error_exit "Usage: $0 <log_file> <keywords_file>"

#If filws does not exist, create it with headers
if [ ! -f "$LOG_FILE" ]; then
    echo "Ticket ID,Status,Details" > "$LOG_FILE"
fi
if [ ! -f "$KEYWORDS_FILE" ]; then
    error_exit "Keywords file not found: $KEYWORDS_FILE"
fi

#Noe we read the keywords file and process each keyword

while IFS= read -r keyword; do
    echo "Processing : $keyword"

    
    
    TICKET_ID=$((RANDOM % 1000 + 1)) 
    
    DETAILS="Details for ticket $TICKET_ID with status $keyword"
   
   
    echo "$TICKET_ID,$keyword,$DETAILS" >> "$LOG_FILE"
done < "$KEYWORDS_FILE"
echo "Ticket processing completed. Details logged in $LOG_FILE"




