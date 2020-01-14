#!/bin/bash

##Courtesy of http://guide.debianizzati.org/index.php/Backup_di_MySQL_tramite_script
## by mm-barabba

#Read configuration from an external file
source config.sh

#File rotation

#Delete old one
if [ -f $FILEOLD ]; then
   rm $FILEOLD
fi

#File rotation
if [ -f $FILE ]; then
   mv $FILE $FILEOLD
fi

#Create the dump
if mysqldump --skip-lock-tables --quote-names -u $NAME --password=$PASS --events --all-databases 2>$LOG_LOCATION >$FILE
then
    echo -e "mysqldump successfully finished at $(date +'%d-%m-%Y %H:%M:%S')"$'\r' >> "$LOG_LOCATION"
else
    echo -e "mysqldump failed at $(date +'%d-%m-%Y %H:%M:%S')"$'\r' >> "$LOG_LOCATION"
fi

chown $OWNER:$OWNER $FILE
chown $OWNER:$OWNER $FILEOLD

exit

