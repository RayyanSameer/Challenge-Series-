: << 'COMMENT'
The User Auditor

Scenario:
The security team is auditing the system. They need a script, user_check.sh, that takes a username as a command-line argument and performs a lookup.

Requirements:

    The script must accept exactly one argument. If the user provides zero arguments or more than one, print a usage message to stderr and exit with status 1.

    Search the /etc/passwd file for that specific username.

    If the user exists:

        Print "User [username] found."

        Print their Home Directory path.

        Print their Default Shell path.

    If the user does not exist:

        Print "User [username] not found." to stderr and exit with status 2.

Constraints:

    You must parse the information directly from /etc/passwd.

    Do not use the id or getent commands (I want to see how you handle string manipulation and delimiters).

    Use cut, awk, or grep to extract the specific fields.

COMMENT
#!/bin/bash
error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

# Check argument count
if [ "$#" -ne 1 ]; then
    error_exit "Usage: $0 <username>" 1
fi

USERNAME="$1"

# Search /etc/passwd
if grep -q "^${USERNAME}:" /etc/passwd; then
    echo "User found:"
    grep "^${USERNAME}:" /etc/passwd | cut -d: -f6,7
else
    error_exit "User '$USERNAME' not found." 2
fi