#!/bin/bash

error_exit(){
    echo :"$1" >&2
    exit "${2:-1}"
}

[[ $# -ne 3 ]] && error_exit "Usage: $0 <employee_name> <employee_email> <department>"
EMPLOYEE_NAME=$1
EMPLOYEE_EMAIL=$2
DEPARTMENT=$3

echo "Creating user account for $EMPLOYEE_NAME..."
useradd -m "$EMPLOYEE_NAME"
if [ $? -ne 0 ]; then
    error_exit "Failed to create user account for $EMPLOYEE_NAME"
fi

echo "Enter department for $EMPLOYEE_NAME (e.g., IT, HR, Finance):"
read -r DEPARTMENT
usermod -aG "$DEPARTMENT" "$EMPLOYEE_NAME"
if [ $? -ne 0 ]; then
    error_exit "Failed to assign permissions for $EMPLOYEE_NAME"
fi

echo "Sending welcome email to $EMPLOYEE_EMAIL..."
echo "Subject: Welcome to the Company, $EMPLOYEE_NAME!" > email.txt
echo "Dear $EMPLOYEE_NAME," >> email.txt
echo "Welcome to the $DEPARTMENT department! Your account has been created with the username: $EMPLOYEE_NAME. Please log in and change your password at your earliest convenience." >> email.txt

