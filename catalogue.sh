#!/bin/bash
USERID=$(id -u) # user id creation
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m" # colors

LOGS_FOLDER="var/log/catalogue-logs" #store the logs
SCRIPT_NAME=$(echo $0 | cut -d "." -f1) # remove the . extenstion
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # add the .log on end
SCRPIT_DIR=$PWD

mkdir -p $LOGS_FOLDER #if already direcotry created ok otherwise created
echo "script started executing : $(date)" | tee -a $LOG_FILE #append the data in log file


if [ $USERID != 0 ]
then
    echo " $R ERROR:: please script run in the root access $N " | tee -a $LOG_FILE 
    exit 1 # filed the script it will use
else   
    echo "your script runing in the root access"

fi

VALIDATE(){

    if [ $1 -eq 0 ]
then 
    echo " $2 Installation ----- $G Sucessfully $N " | tee -a $LOG_FILE #append # green color provided on sucessfully word
else   
    echo " $2 Installation ------ $R Failed $N "  | tee -a $LOG_FILE #append#Red color provided on failed word
    exit 1 # exit 1 indicates faild the script
fi
    
}

dnf module list nodejs &&>>LOG_FILE
VALIDATE $? "Nodejs Module List"
dnf module disable nodejs -y &&>>LOG_FILE
VALIDATE $? "Nodejs Disable"
dnf module enable nodejs:20 -y &&>>LOG_FILE
VALIDATE $? "Nodejs Enable"
dnf install nodejs -y &&>>LOG_FILE
VALIDATE $? "Install Nodejs"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &&>>LOG_FILE
VALIDATE $? "Roboshop System User"
mkdir -p /app
VALIDATE $? "Create App Directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &&>>LOG_FILE
VALIDATE $? "Dowanload Catalogue Code"
cd /app 
unzip /tmp/catalogue.zip &&>>LOG_FILE
VALIDATE $? "Unzip Catalogue code"

npm install &&>>LOG_FILE
VALIDATE $? "Install Dependency"

cp $SCRPIT_DIR/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload &&>>LOG_FILE
VALIDATE $? "Restart Server"

systemctl enable catalogue &&>>LOG_FILE
VALIDATE $? "Enable Catalogue Server"

systemctl start catalogue  &&>>LOG_FILE
VALIDATE $? "Start Catalogue Service"

cp $SCRPIT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &&>>LOG_FILE
VALIDATE $? "Install client Server"

mongosh --host mongodb.tadikondadevops.site </app/db/master-data.js &&>>LOG_FILE
VALIDATE $? "Load Master Data"