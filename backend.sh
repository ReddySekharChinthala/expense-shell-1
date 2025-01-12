#/bin/bash


source ./common.sh

check_root

echo "please enter the password:"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE

dnf module enable nodejs:20 -y &>>$LOGFILE

dnf install nodejs -y &>>$LOGFILE


id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    
else
    echo -e "User already exist..$Y SKIPPING $N"
fi

# below -p is to check whether exist app directory is there are not if its there it will ignore, otherwise it will give error.
mkdir -p /app &>>$LOGFILE


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE


cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE


npm install &>>$LOGFILE


#here if we check in putty shell for pwd the below path will come and after 2nd path from etc/ copied from doc
cp /home/ec2-user/expense-shell-1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE


systemctl daemon-reload &>>$LOGFILE


systemctl start backend &>>$LOGFILE


systemctl enable backend &>>$LOGFILE


dnf install mysql -y &>>$LOGFILE


mysql -h db.rsdevops78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE


systemctl restart backend &>>$LOGFILE
