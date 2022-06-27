# Backup mysql using mysqldump
Allows to backup all the database in a collective dump, keeping routines and users, quoting names, and dumping events.

## Config
A config file is required. It will be created at first use if not present.
The structure is similar to:

    #!/bin/bash
    # Mysql backup configuration
    FILE="/mybackup/Mysql.sql"
    FILEOLD="/mybackup/Mysql.old.sql"
    LOG_LOCATION="/mybackup/Mysql.log"

    OWNER="myuser"

    #Optional when using classic authentication
    #Let it commented when using system authentication
    #NAME="root"
    #PASS="password"


## Execution
The execution of this file can be planned with crontab, normally as root user:
37 18 * * 5     /bin/bash -c "/home/mydir/backupMysql.sh"

This command will create a backup file and a new file.

## Manage
To manage the dump you can use:
[dumpSeparator](https://github.com/canonex/dumpSeparator)