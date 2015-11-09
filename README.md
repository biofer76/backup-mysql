Dump / Backup a MySQL container database in gzip format
============================
You can backup your MySQL database by this container that running mysqldump tool after an interval of N seconds.

HOWTO
-----
Create a new database container or use an existing one.
If you don't have a database container or want to test it before running in production run a new mysql container:

    docker \
    run \
    --detach \
    --env MYSQL_ROOT_PASSWORD=myrootpassword \
    --env MYSQL_USER=myuser \
    --env MYSQL_PASSWORD=userpassword \
    --env MYSQL_DATABASE=mydb \
    --name mysql-test \
    --publish 3306:3306 \
    mysql:5.6;
   
 Run **backup-mysql** container to perform backups

    docker run -d \
    --name [NAME OF YOUR BACKUP CONTAINER] \
    --env BACKUP_INTERVAL=[SECONDS] \
    --link /[MYSQL CONTAINER NAME]:mysql \
	-v [HOST PATH]:/var/backups/ \
    particles/backup-mysql

Example:

    docker run -d \
    --name backup-mysql \
    --env BACKUP_INTERVAL=300 \
    -v /host/path/backup:/var/backups \
    --env MYSQL_DATABASE=mydb
    --link /mysql-test:mysql \
    particles/backup-mysql

Settings:
--------------------------------
`BACKUP_INTERVAL`: interval between backups expressed in seconds, without that will be used a default value of 24 hours (3600*24). First backup and interval start from the container run

`/host/path/backup`: set host path to save backups, don't change container default folder (*/var/backups/*)

`MYSQL_DATABASE`: Environment variable you can use in backup or mysql container (backup container env variable has priority)


After running backup container you can check logs:

    docker logs -f backup-mysql

If everything's gone well you can see:

    [06/11//2015 11:58]: Writing backup N. 1 for 172.17.0.1:3306/mydb
    [06/11/2015 12:00]: Backup of mydb completed in 1 minutes and 45 seconds and dump filesize is 1022705671 bytes

Check your host folder to find database dump in gzip format

    ls -l /path/where/backup/mysql/
    mydb.sql.gz

