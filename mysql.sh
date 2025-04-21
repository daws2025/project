#!/bin/bash
USERID=$(id -u)

R="[\e31m"
Y="[\e33m"
G="[\e32m"
N="[\e0m"

LOG_FOLDER="/var/log/project-logs"
LOG_FILE=$(echo $0 | cut -d '.' -f1)
TIMESTAMP=$(date +%Y-%m-%d) 
LOGS="$LOG_FOLDER/$LOG_FILE_$TIMESTAMP.log"

mkdir -p /var/log/project-logs

VALIDATE()
if [ $1 -ne 0 ]
then
    echo -e "$2 is $R FAILURE $N"
else
    echo -e "$2 is $G SUCCESS $N"
fi

CHECK_ROOT()
if [ $USERID -ne 0 ]
then
    echo "$R You do not have sudo access $N"
    exit 1
fi

echo "Script started at $TIMESTAMP" &>>LOGS

CHECK_ROOT

dnf install mysql-server -y &>>LOGS
VALIDATE $? "Installing MYSQL Server"

systemctl enable mysqld &>>LOGS
VALIDATE $? "Enabling MYSQL Server"

systemctl start mysqld &>>LOGS
VALIDATE $? "Starting MYSQL Server"

mysql_secure_installation --set-root-pass ExpenseApp@1 
VALIDATE $? "Setting root password"
