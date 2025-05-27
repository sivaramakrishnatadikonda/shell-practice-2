#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="var/log/roboshop-logs" # store the longs
SCRIPT_NAME=$(echo $0 | cut -d "."  -f1) # remove the .extenstion
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER # create parent directory
echo "Script started executing at : $(date)" | tee -a $LOG_FILE # append

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE #append
    exit 1 #exit status give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE #append
fi
# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE #append
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE #append
        exit 1 # exit status code is filed"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Copying MongoDB repo"

dnf install mongodb-org -y &>>$LOG_FILE #stored output
VALIDATE $? "Installing mongodb server"

systemctl enable mongod &>>$LOG_FILE #stored output
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOG_FILE #stored output
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf # -i perminatly changed
VALIDATE $? "Editing MongoDB conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE #stored output
VALIDATE $? "Restarting MongoDB"