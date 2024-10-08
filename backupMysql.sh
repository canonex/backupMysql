#!/bin/bash

#Copyright (c) 2018 Riccardo Gagliarducci <riccardo@brixel.it>
#https://github.com/canonex/dumpSeparator

#This is free software.  You may redistribute copies of it under the terms of the GNU General Public License.
#There is NO WARRANTY, to the extent permitted by law.

# The execution of this file can be planned with crontab, normally as root user:
# 37 18 * * 5     /bin/bash -c "/home/mydir/backupMysql.sh"
#
# @author: Brixel - Riccardo Gagliarducci <riccardo@brixel.it>
# @license: GNU v3
# @date: January 14, 2020
#
# Version 0.2

##Courtesy of http://guide.debianizzati.org/index.php/Backup_di_MySQL_tramite_script
## by mm-barabba


if [ "$(whoami)" != "root" ]; then
	logger "BackupMysql.sh | ERROR | This script should be executed as root"
	echo "$(tput setaf 1)  * "; echo  "  This script should be executed as root"; echo "  * $(tput sgr 0)_"; 
	exit 1
fi


#Check if command installed
command -v mysqldump >/dev/null 2>&1 || { echo "$(tput setaf 1)Command mysqldump not found. Exiting. $(tput sgr 0)"; exit 1; }



#Current script dir
#Courtesy of https://stackoverflow.com/a/246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CONF="$DIR/config.sh"


#Read configuration from an external file
if [ -f "$CONF" ]; then

	# shellcheck source=./config.sh
	source "$CONF"

else

	logger "BackupMysql.sh | ERROR | Cannot find configuration file: please fill in all fields in the newly created config.sh (owned by $USER)"
	echo "$(tput setaf 1)  * "; echo  "  Cannot find configuration file: please fill in all fields in the newly created config.sh"; echo "  * $(tput sgr 0)_"; 
	

	echo '
#!/bin/bash

# Mysql backup configuration
FILE="/home/user/my.sql"
FILEOLD="/home/user/my.old.sql"
LOG_LOCATION="/root/mysqlbackup.log"
OWNER="fileowner"

#Optional
NAME="root"
PASS="password"
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



#Mysql is using system authentication?
#Just don't set name or set it to empty
if [ -n "$NAME" ]; then
  echo "Using named authentication."

	#Create the dump
	if mysqldump --skip-lock-tables --quote-names --routines --events --all-databases -u $NAME --password=$PASS 2>"$LOG_LOCATION" >"$FILE"
	then
		echo -e "mysqldump successfully finished at $(date +'%d-%m-%Y %H:%M:%S')"$'\r' | tee -a "$LOG_LOCATION"
	else
		echo -e "mysqldump failed at $(date +'%d-%m-%Y %H:%M:%S')"$'\r' | tee -a "$LOG_LOCATION"
		logger "BackupMysql.sh | Failed $?"
		exit 1
	fi

else
  echo "Using system authentication."

	#Create the dump
	if mysqldump --skip-lock-tables --quote-names --routines --events --all-databases 2>"$LOG_LOCATION" >"$FILE"
	then
		echo -e "mysqldump successfully finished at $(date +'%d-%m-%Y %H:%M:%S')"$'\r' | tee -a "$LOG_LOCATION"
	else
		echo -e "mysqldump failed at $(date +'%d-%m-%Y %H:%M:%S')"$'\r' | tee -a "$LOG_LOCATION"
		logger "BackupMysql.sh | Failed $?"
		exit 1
	fi

fi




#File permissions
if [ -f "$FILE" ]; then
	chown "$OWNER":"$OWNER" "$FILE"
fi

#File permissions
if [ -f "$LOG_LOCATION" ]; then
	chown "$OWNER":"$OWNER" "$LOG_LOCATION"
fi





logger "BackupMysql.sh | End"

exit 0

