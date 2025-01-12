#/bin/bash

source ./common.sh

check_root

echo "please enter the password:"
read -s mysql_root_password

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "enabling mysql server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "startting mysql server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "setting up root password"

# #Below code will be useful for idempotent nature

mysql -h db.rsdevops78s.online -uroot -pExpenseApp@1 -e 'SHOW DATABASES;' &>>$LOGFILE
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MyyyssSQL_Root_Password_SetUP"
else
    echo -e "mysql root setup password is alread set..$G SKIPPING $N" 
fi
