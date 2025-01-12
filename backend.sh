#/bin/bash


source ./common.sh

check_root

echo "please enter the password:"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "User already exist..$Y SKIPPING $N"
fi

# below -p is to check whether exist app directory is there are not if its there it will ignore, otherwise it will give error.
mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

#here if we check in putty shell for pwd the below path will come and after 2nd path from etc/ copied from doc
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reloading"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend service"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql schemas"

mysql -h db.rsdevops78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend service"