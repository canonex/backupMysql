#!/bin/bash
#
# This file should be executable

# The execution of this file can be planned with crontab, normally as root user:
# 37 18 * * 5     /bin/bash -c "/home/mydir/backupMysql.sh > /root/backupMySql.log"
#
# @author: Brixel - Riccardo Gagliarducci <riccardo@brixel.it>
# @license: GNU v3
# @date: January 14, 2020
#
# Version 0.2

##Courtesy of http://guide.debianizzati.org/index.php/Backup_di_MySQL_tramite_script
## by mm-barabba


logger "BackupMysql.sh | Start"

#Current script dir
#Courtesy of https://stackoverflow.com/a/246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CONF="$DIR/config.sh"


#Read configuration from an external file
if [ -f "$CONF" ]; then

	source "$CONF"

else

	logger "BackupMysql.sh | Cannot find configuration file: please fill in all fields in the newly created config.sh (owned by $USER)"

	echo '
	#!/bin/bash

	# Mysql backup configuration
	FILE="/home/user/my.sql"
	FILEOLD="/home/user/my.old.sql"
	LOG_LOCATION="/root/mysqlbackup.log"
	NAME="root"
	PASS="password"
	OWNER="fileowner"
	' > "$CONF"

	chown "$OWNER":"$OWNER" "$CONF"

	exit 1
fi



#File rotation

#Delete old one
if [ -f "$FILEOLD" ]; then
	rm "$FILEOLD"
fi

#File rotation
if [ -f "$FILE" ]; then
	mv "$FILE" "$FILEOLD"
	chown "$OWNER":"$OWNER" "$FILEOLD"
fi



#Create the dump
if mysqldump --skip-lock-tables --quote-names -u "$NAME" --password="$PASS" --events --all-databases 2>"$LOG_LOCATION" >"$FILE"
then
	echo -e "mysqldump successfully finished at $(date +'%d-%m-%Y %H:%M:%S')"$'\r' >> "$LOG_LOCATION"
	chown "$OWNER":"$OWNER" "$FILE"
else
	echo -e "mysqldump failed at $(date +'%d-%m-%Y %H:%M:%S')"$'\r' >> "$LOG_LOCATION"
	logger "BackupMysql.sh | Failed $?"
	exit 1
fi

logger "BackupMysql.sh | End"

exit 0

