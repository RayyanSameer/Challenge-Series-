#WHAT : A Bash Script that reads tickets based on the keywords (Like : Resolved, Closed, Open) and then automatically logs the details in a CSV file for record-keeping and analysis.

#GOAL : To automate the process of tracking and managing tickets, making it easier to analyze trends and performance over time.

KEYWORDS_FILE="keywords.txt"
TICKET_LOGS="ticket_logs.csv"

error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}
 
[[ ! -f "$KEYWORDS_FILE" ]] && error_exit "Keywords file not found: $KEYWORDS_FILE"
[[ ! -f "$TICKET_LOGS" ]] && echo "Ticket ID,Status,Date" > "$TICKET_LOGS"

#Note to sel: always check if the file exists before trying to read it. If not, create it with headers.


#PSUDOCODE
#1. Read keywords from the file
#2. For each keyword, search the ticket system (simulate with echo for now)
#3. Extract relevant details (simulate with random data)
#4. Append details to the CSV log file
echo " Search based on keyword"
echo "-----------------------"

while IFS= read -r keyword 
