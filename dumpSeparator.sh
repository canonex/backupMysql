#!/bin/bash
#Courtesy of https://stackoverflow.com/questions/16483119/an-example-of-how-to-use-getopts-in-bash

#Courtesy of https://stackoverflow.com/questions/4332478/read-the-current-text-color-in-a-xterm/4332530#4332530
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
LIME_YELLOW=$(tput setaf 190)
CYAN=$(tput setaf 6)

usage() { echo "Usage: $0 extract|purge databasename dumpinputfile" 1>&2; exit 1; }


#If subcommands exists and they are extract or purge
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
	printf "One command, one database name and one mysql dump file expected.\n\n"
	usage
	exit 1
fi

printf "\n"

#Making a backup
cp $3 $3.old

case $1 in
	extract)
        printf "%40s\n" "Extracting ${LIME_YELLOW}$2${NORMAL} from $3"

		#Keeping text until "Dumping", keeping text after "Current"...
		sed -i -e "/-- Dumping events for database '$2'/q" -e '/-- Current Database: `'"$2"'`/,$!d' $3

		fname="${3%.*}"_$2.sql
		mv $3 $fname
        ;;
     
    purge)
        printf "%40s\n" "Purging ${RED}$2${NORMAL} from $3"

		#Keeping from beginning to end
		sed -i "/-- Current Database: \`$2\`/,/-- Dumping events for database '$2'/d" $3

		fname="${3%.*}"_purged.sql
		mv $3 $fname
        ;;
    *)
		printf "%40s\n" "Command can be extract or purge.\n\n"
		usage
        exit 1
esac

printf "\n\n"

exit 0
