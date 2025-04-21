#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/project-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-+%m-+%d)
LOGS=$LOG_FOLDER/$LOG_FILE-$TIMETSTAMP.log

VALIDATE()
{
    if [ $1 -ne 0 ]
    then   
        echo -e "$2 is $R failure $N" 
    else 
        echo -e "$2 is $G success $N" 
    fi
}

CHECK_ROOT()
{
    if [ $USERID -ne 0 ]
    then
        echo -e "$R you don't have root access $N"
        exit 1
    fi
}

mkdir -p /var/log/project-logs

echo -e "script started executing at $G $TIMESTAMP $N" &>>LOGS

CHECK_ROOT

dnf install nginx -y &>>$LOGS
VALIDATE $? "installing nginx"

systemctl enable nginx -y &>>$LOGS
VALIDATE $? "enabling nginx"

systemctl  start nginx -y &>>$LOGS
VALIDATE $? "starting nginx" 

rm -rf /usr/share/nginx/html/* &>>$LOGS
VALIDATE $? "removing default content nginx"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGS
VALIDATE $? "downloading zip file"

cd /usr/share/nginx/html &>>$LOGS
VALIDATE $? "moving to html dir"

dnf install zip unzip -y &>>$LOGS
VALIDATE $? "installing zip unzip"

unzip /tmp/frontend.zip
VALIDATE $? "extracting zipped files" &>>$LOGS

cp /home/brucelee/project/project.conf /etc/nginx/default.d/expense.conf &>>$LOGS
VALIDATE $? "Copied expense config"

systemctl restart nginx &>>$LOGS
VALIDATE $? "Restarting nginx"