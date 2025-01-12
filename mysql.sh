#/bin/bash

source ./common.sh

check_root

echo "please enter the password:"
read -s mysql_root_password

dnf install mysql-server -y &>>$LOGFILE

systemctl enable mysqld &>>$LOGFILE

systemctl start mysqld &>>$LOGFILE

mysql -h db.rsdevops78s.online -uroot -p${mysql_root_password} -e 'SHOW DATABASES;' &>>$LOGFILE
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    
else
    echo -e "mysql root setup password is alread set..$G SKIPPING $N" 
fi
