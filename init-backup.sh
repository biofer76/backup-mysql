#!/bin/bash

# Environment variables linked from mysql container
# MYSQL_ENV_MYSQL_DATABASE - Database name to backup
# MYSQL_ENV_MYSQL_ROOT_PASSWORD - root password to excute backup
# MYSQL_PORT_3306_TCP_ADDR - IP Address of mysql container
# MYSQL_PORT_3306_TCP_PORT - Port of mysql container


# interval between backups in seconds
if [[ ! -v BACKUP_INTERVAL ]]
then

  BACKUP_INTERVAL=$((3600*24))   # default 24 hours
fi

interval=$BACKUP_INTERVAL

# MySQL configuration
dbhost=$MYSQL_PORT_3306_TCP_ADDR
dbport=$MYSQL_PORT_3306_TCP_PORT
dbname=$MYSQL_ENV_MYSQL_DATABASE
dbuser="root"
dbpass=$MYSQL_ENV_MYSQL_ROOT_PASSWORD
dbfolder="/var/backups"

echo "Starting MySQL backup script for database $dbname with an interval of $interval seconds "

count=1

while [ 1 ]
do
	# Set filename 
    filename=$dbname.sql.gz
    
    date1=$(date -u +"%s")
    datetime=`date +"%d/%m/%Y %H:%M"`
    echo "[$datetime]: Writing backup N. $count for $dbhost:$dbport/$dbname"
    
    # Execute backup with mysqldump
    mysqldump -h $dbhost -P $dbport -u $dbuser --password="$dbpass" $dbname | /bin/gzip > "$dbfolder/$filename"

	date2=$(date -u +"%s")
	diff=$(($date2-$date1))

    datetime=`date +"%d/%m/%Y %H:%M"`
	# Manage dump result
	if [ "$?" -eq 0 ]
	then
		dbsize=$(stat -c%s "$dbfolder/$filename")
	    echo "[$datetime]: Backup of $dbname completed in $(($diff / 60)) minutes and $(($diff % 60)) seconds and dump filesize is $dbsize bytes"
	else
    	echo "[$datetime]: Database dump encountered a problem look in database.err for information"
	fi
   
    # increment counter
    count=`expr $count + 1`
    
    # Waiting next backup execution 
    sleep $interval
    
done
