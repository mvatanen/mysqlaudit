#https://github.com/mvatanen

#!/bin/bash

echo "Enter your username for mysql (root recommended)";
read username;
echo "Enter password (password not shown)";
unset password;
while IFS= read -r -s -n1 pass; do
  if [[ -z $pass ]]; then
     echo
     break
  else
     echo -n '*'
     password+=$pass
  fi
done
echo "CREATING DIRECTORIES : RESULTS AND TMP"
mkdir -p results
mkdir -p tmp

echo "Time and Date" >> results/System_info.txt
echo 'select NOW()'| mysql -u$username -p$password >> results/System_info.txt

echo "MYSQL VERSION" >> results/System_info.txt
echo 'show variables like "%version%"'| mysql -u$username -p$password >> results/System_info.txt

echo "USERS" >> results/Users.txt
echo 'select user,host from mysql.user'| mysql -u$username -p$password >> results/Users.txt

echo "CURRENT USERS" >> results/Users.txt
echo 'show processlist'| mysql -u$username -p$password >> results/Users.txt

echo "ALL VARIABLES" >> results/All_variables.txt
echo 'show variables'| mysql -u$username -p$password >> results/All_variables.txt

echo "DATABASES" >> results/Databases.txt
echo 'show databases'| mysql -u$username -p$password >> results/Databases.txt 
echo 'show databases'| mysql -u$username -p$password |grep -v Database>> results/mysql_databases

echo "ALL TABLES FROM ALL DATABASES" >> results/Tables_from_databases.txt
echo 'select table_schema, table_name from information_schema.tables'| mysql -u$username -p$password >> results/Tables_from_databases.txt
echo 'select table_schema, table_name from information_schema.tables'| mysql -u$username -p$password >> results/mysql_tables

echo "TABLES FROM ALL DATABASES EXCEPT INTERNAL" >> results/Not_system_tables.txt 
echo "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ( 'information_schema', 'performance_schema', 'mysql' )"| mysql -u$username -p$password >> results/Not_system_tables.txt

#TABLES AND TABLE STATUSES
while read dbname
do
mysql --batch -u$username -p$password -t $dbname<sql/show_tables.mysql|sed '1d;2d;3d;$d'|cut -d '|' -f2|tr -d ' ' >> tmp/$dbname
echo "TABLE STATUS FROM $dbname" >> results/Table_status.txt
mysql --batch -u$username -p$password -t $dbname < sql/show_table_status.mysql >> results/Table_status.txt
done < results/mysql_databases

#TABLE DESCRIPTIONS
while read db
do
 for table in `cat "tmp/$db"`
 do
echo "DESCRIPTION OF TABLE $table FROM DATABASE $db" >> results/Table_descriptions.txt
mysql --batch -u$username -p$password  -t $db --execute "desc $table\G" >> results/Table_descriptions.txt
 done
done < results/mysql_databases

echo "AVAILABLE PRIVILEGES" >> results/Available_privileges.txt
echo 'show privileges'| mysql -u$username -p$password >> results/Available_privileges.txt

echo "PRIVILEGES GRANTED TO A PARTICULAR MYSQL ACCOUNT" >> results/Specific_account_privileges.txt
echo "show grants for 'root'@'%'; SELECT user, host FROM mysql.user; SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') FROM mysql.user" | mysql -u$username -p$password >> results/Specific_account_privileges.txt


#ALL PRIVILEGES 
while read dbname
do
echo "GLOBAL PRIVILEGES OF $dbname" >> results/GLobal_privileges.$dbname.txt
mysql -u$username -p$password -t $dbname <sql/global_privileges.mysql >> results/Global_privileges.$dbname.txt 

echo "DATABASE PRIVILEGES OF $dbname" >> results/Database_privileges.$dbname.txt
mysql -u$username -p$password -t $dbname <sql/database_privileges.mysql >> results/Database.privileges.$dbname.txt 

echo "TABLE PRIVILEGES OF $dbname" >> results/Table_privileges.$dbname.txt
mysql -u$username -p$password -t $dbname <sql/table_privileges.mysql >> results/Table_privileges.$dbname.txt 

echo "TABLE_COLUMN PRIVILEGES OF $dbname" >> results/Table_column_privileges.$dbname.txt
mysql -u$username -p$password -t $dbname <sql/table_column_privileges.mysql >> results/Table_column_privileges.$dbname.txt

echo "TABLE_COLUMN_VIEW PRIVILEGES OF $dbname" >> results/Table_column_view_privileges.$dbname.txt
mysql -u$username -p$password -t $dbname <sql/table_column_view_privileges.mysql >> results/Table_column_view_privileges.$dbname.txt

echo "VIEW PRIVILEGES OF $dbname" >> results/View_privileges.$dbname.txt.txt
mysql -u$username -p$password -t $dbname <sql/view_privileges.mysql >> results/View_privileges.$dbname.txt

echo "PROCEDURE PRIVILEGES OF $dbname" >> results/Procedure_privileges.$dbname.txt
mysql -u$username -p$password -t $dbname <sql/procedure_privileges.mysql >> results/Procedure_privileges.$dbname.txt

echo "FUNCTIONS PRIVILEGES OF $dbname" >> results/Function_privileges.$dbname.txt
mysql -u$username -p$password -t $dbname <sql/functions_privileges.mysql >> results/Function_privileges.$dbname.txt
done < results/mysql_databases

#TABLE INDEXES
while read dbname
do
 for table in `cat "tmp/$dbname"`
 do
echo "INDEX OF TABLE $table FROM DATABASE $dbname" >> results/Table_index.$dbname.txt
mysql --batch -u$username -p$password --execute "show index from $table from $dbname" >> results/Table_index.$dbname.txt
 done
done < results/mysql_databases

echo "GRANTS" >> results/GRANTS.txt
echo 'show grants\G' | mysql -u$username -p$password >> results/GRANTS.txt

#GRANTS ALL USERS
mysql --batch -u$username -p$password --execute "select concat('\'',User,'\'@\'',Host,'\'') as User from mysql.user"|sed '1d' >> tmp/users
while read user
do
mysql --batch -u$username -p$password --execute "show grants for $user" | sed 's/$/;/' >> results/Grants_and_users.txt
done < tmp/users


