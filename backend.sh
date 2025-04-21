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
dnf module disable nodejs -y &>>LOGS
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>LOGS
VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>>LOGS
VALIDATE $? "installing nodejs"

id expense &>>LOGS
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "adding user"
else
    echo -e "user already exists $Y SKIPPING $N"
fi

mkdir -p /app &>>LOGS
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOGS
VALIDATE $? "Downloading app team's package"

cd /app &>>LOGS
rm -rf * 
VALIDATE $? "Removing all files from App.dir"

dnf install zip unzip -y &>>LOGS
VALIDATE $? "installing zip unzip"

unzip /tmp/backend.zip &>>LOGS
VALIDATE $? "Extracting files from zip file"

npm install &>>LOGS
VALIDATE $? "installing dependencies"

cp /home/brucelee/project/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copying .service file"

dnf install mysql -y
VALIDATE $? "installing MYSQL client"

mysql -h mysql.daws82s.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGS
VALIDATE $? "Setting up the transactions schema and tables"

systemctl daemon-reload &>>$LOGS
VALIDATE $? "Daemon Reload"

systemctl enable backend &>>$LOGS
VALIDATE $? "Enabling backend"

systemctl restart backend &>>$LOGS
VALIDATE $? "Starting Backend"