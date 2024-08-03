# description: backup restore notes
# reference: https://docs.moodle.org/404/en/Site_backup

# get password for moodle "user" and database user "admin"
sudo cat /home/bitnami/bitnami_credentials

# backup database
mariadb-dump --default-character-set=utf8mb4 -h $HOSTNAME -u $DBUSER --password=$DBPASSWORD -C -Q -e --create-options $DBNAME > moodle-database.sql

# compress database backup
gzip moodle-database.sql

# backup moodle data
sudo tar czvf moodledata.tgz /bitnami/moodledata/

# determine moodle code location
ps -ef | grep apache
grep ServerRoot /opt/bitnami/apache/conf/httpd.conf | grep -v '^#'

# backup moodle code
sudo tar czvf html.tgz /opt/bitnami/apache

# get md5 checksum to verify transfer later
md5sum moodle-database.sql.gz moodledata.tgz html.tgz 

# services contol
sudo /opt/bitnami/ctlscript.sh stop|start|restart apache|mariadb|php-fpm

# login database.. 
sudo mariadb -u root -p

# OR, create database, user, grant privileges
mysql -u root -p$DBROOTPASSWORD -e "CREATE DATABASE my_new_database;"
mysql -u root -p$DBROOTPASSWORD -e "CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'secure_password';"
mysql -u root -p$DBROOTPASSWORD -e "GRANT ALL PRIVILEGES ON my_new_database.* TO 'new_user'@'localhost';"
mysql -u root -p$DBROOTPASSWORD -e "FLUSH PRIVILEGES;"

# decompress database
gzip -d moodle-database.sql.gz

# restore database
mariadb -u $DBUSER -p $DBNAME  < moodle-database.sql 

# restore moodle data
sudo tar zxf ~/moodledata.tgz -C /
