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
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE #append
    exit 1 # filed the script it will use
else   
    echo "your script runing in the root access"

fi

VALIDATE(){

    if [ $1 -eq 0 ]
then 
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE #append
else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE #append
        exit 1 # exit 1 indicates faild the script
fi
    
}

dnf module list nginx
VALIDATE $? "Module List of Nginx"

dnf module disable nginx -y
VALIDATE $? "Disable Nginx"

dnf module enable nginx:1.24 -y
VALIDATE $? "Enable Nginx:1.24 Version"

dnf install nginx -y
VALIDATE $? "Install Nginx"


systemctl enable nginx 
VALIDATE $? "Enable Nginx"

systemctl start nginx 
VALIDATE $? "Start Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove Previous html file"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Dowanload Code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Unzip Code"


cp $SCRPIT_DIR/nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx &&>>LOG_FILE
VALIDATE $? "Restart Nginx"