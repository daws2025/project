#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/project-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-+%m-+%d)
LOGS=$LOG_FOLDER/$LOG_FILE-$TIMETSTAMP.log

SRC_DIR=$1
DEST_DIR=$2
DAYS=$(3:-14)  #if user is not providing any value for no. of days, 14 will be default

USERID=$(id -u)
CHECK_ROOT()
if [ $USERID -ne 0 ]
then
    echo "you don't have root access"
    exit 1
fi

USAGE
{
    echo -e "$R USAGE:: $N sh old-logs.sh SRC_DIR DEST_DIR Days(Optional)"
}

if [ $# -lt 2 ]
then
    USAGE
    exit 1
fi

if [ ! -d $SRC_DIR ]
then
    echo "$SRC_DIR does not exist"
    exit 1
fi

if [ ! -d $DEST_DIR ]
then
    echo "$DEST_DIR does not exist"
    exit 1
fi

FILES=$(find $SRC_DIR -name "*.log" -mtime +$DAYS)

CHECK_ROOT
dnf install zip unzip -y

if [ -n $FILES ]
then
    ZIP_FILE=$("$DEST_DIR/app-logs-$TIMESTAMP.zip")
    $FILES | zip -@ $ZIP_FILE
    if [ -f "$ZIP_FILE" ]
    then
        echo "zip file created successfully"
        while read -r filepath
        do
            echo "deleting file $filepath"
            rm -rf $filepath
        done<<<$FILES
    else
        echo "zip file is not created"
        exit 1
    fi
else
    echo "there are no files to zip"
    exit 1
fi


