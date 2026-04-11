#!/bin/bash
#User Onboarding.sh

#This script is designed to automate the user onboarding process in an office environment. It will create a new user account, set up necessary permissions, and send a welcome email to the new employee.

#Pseudocode:
#1. Get user input for new employee details (name, email, department)
#2. Create a new user account in the system
#3. Assign necessary permissions based on the department
#4. Send a welcome email to the new employee with their account details



error_exit(){
    echo "$1" >&2
    exit "${2:-1}"

}
[[ $# -ne 3 ]] && error_exit "Usage: $0 <employee_name> <employee_email> <department>"
EMPLOYEE_NAME=$1
EMPLOYEE_EMAIL=$2
DEPARTMENT=$3

#Simulate user account creation
echo "Creating user account for $EMPLOYEE_NAME..."

useradd -m "$EMPLOYEE_NAME" 
if [ $? -ne 0 ]; then
    error_exit "Failed to create user account for $EMPLOYEE_NAME"
fi

usermod -aG "$DEPARTMENT" "$EMPLOYEE_NAME"
if [ $? -ne 0 ]; then
    error_exit "Failed to assign permissions for $EMPLOYEE_NAME"
fi

echo "Sending welcome email to $EMPLOYEE_EMAIL..."
echo "Subject: Welcome to the Company, $EMPLOYEE_NAME!" > email.txt
echo "Dear $EMPLOYEE_NAME," >> email.txt
echo "Welcome to the $DEPARTMENT department! Your account has been created with the username: $EMPLOYEE_NAME. Please log in and change your password at your earliest convenience." >> email.txt