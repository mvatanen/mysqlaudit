# mysqlaudit
Shell script that can be user to query data from Mysql database for audit or security purposes.

# Description

Script uses bash, mysql binary and sql-files (renamed here to .mysql so they don't get mixed with other database vendors) to fetch metadata from mysqldatabases. Idea is to get basic information from Mysql and use that to get forward automatically.

# Howto

Copy script and "sql/" folder to server that has mysql server installed.

Give mysql-audit.sh script execution rights : chmod +x mysql-audit.sh.

You don't need to be logged in as root in the OS, but you need rights to call mysql commands and root access to Mysql itself.

Results go to results/ folder.

# Other information
 
Script doesn't copy actual data from the database but some (all? information should be handled carefully. 

Note that especially results/Grants_users.txt contains some user data that you might want to handle extra carefully.


# Sources

Some of the sql file contents are taken from

http://blog.devart.com/how-to-get-a-list-of-permissions-of-mysql-users.html




