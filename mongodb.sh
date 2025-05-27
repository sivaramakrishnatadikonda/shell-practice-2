#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="var/log/shell-practice-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then 
    echo "ERROR:: please run the script in root access"
    exit 1
else
    echo "your are in root access"
fi
VALIDATION(){

if [ $! -eq 0 ]
then 
     echo " $2  Installation ---------  $G sucessfully $N " 
else
     echo "$2 Installation -------- $R Failed $N "
     exit 1
fi 

}

for package in $@
do
dnf list module $package
if [ $? -eq 0 ]
then 
    echo "Installation is not completed pleaase compelted"
dnf install $package -y
VALIDATION $? "$package"
else
    echo "Instalation is already completed please $Y skipped $N "
fi
done
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &&>>LOG_FILE 
VALIDATE $? "Installing Mongodb Server" 

systemctl enable mongod &&>>LOG_FILE
VALIDATE $? "Enable Mongodb Server" 

systemctl start mongod &&>>LOG_FILE
VALIDATE $? "Start the Mongodb Server" 

sed -i 's/127.0.0.1/0.0.0.0' /etc/mongod.conf # perminatly replace the 0.0.0.0 in config file

systemctl restart mongod &&>>LOG_FILE
VALIDATE $? "Restart the Mongodb Server" 