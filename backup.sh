#!/bin/bash
set -eu 
IFS=$'\n\t'
 
##############################
## POSTGRESQL BACKUP CONFIG ##
##############################

# Optional hostname to adhere to pg_hba policies. Will default to "localhost" if none specified.
HOSTNAME=${POSTGRES_HOST:-localhost}
 
# Optional username to connect to database as. Will default to "postgres" if none specified.
USERNAME=${POSTGRES_USER:-postgres}
 
# Optional password to connect to database as. Will default to empty if none specified.
export PGPASSWORD=${POSTGRES_PASSWORD:-}

# This dir will be created if it doesn't exist.  This must be writable by the user the script is
# running as.
BACKUP_DIR=${BACKUP_DIR:-/var/lib/postgresql/backup}
 
# Will produce gzipped sql file containing the cluster globals, like users and passwords, if set to "yes"
ENABLE_GLOBALS_BACKUPS=${BACKUP_GLOBALS:-yes}

#### SETTINGS FOR ROTATED BACKUPS ####
 
# Which day to take the weekly backup from (1-7 = Monday-Sunday). Will default to 5 if none specified.
DAY_OF_WEEK_TO_KEEP=${BACKUP_RETENTION_DAY_OF_WEEK_TO_KEEP:-5}
 
# Which day to take the monthly backup from. Will default to 1 if none specified.
DAY_OF_MONTH_TO_KEEP=${BACKUP_RETENTION_DAY_OF_MONTH_TO_KEEP:-1}
 
# Number of days to keep daily backups
DAILY_BACKUP_RETENTION_DAYS=7
 
# How many weeks to keep weekly backups
WEEKLY_BACKUP_RETENTION_DAYS=31

MONTHLY_BACKUP_RETENTION_DAYS=365
 
###########################
#### START THE BACKUPS ####
###########################
 
function perform_backups()
{
	SUFFIX=$1
	FINAL_BACKUP_DIR=$BACKUP_DIR/"`date +\%Y-\%m-\%d`$SUFFIX/"
 
	echo "Making backup directory in $FINAL_BACKUP_DIR"
 
	if ! mkdir -p $FINAL_BACKUP_DIR; then
		echo "Cannot create backup directory in $FINAL_BACKUP_DIR. Go and fix it!" 1>&2
		exit 1;
	fi;
 
	#######################
	### GLOBALS BACKUPS ###
	#######################
 
	echo -e "\n\nPerforming globals backup"
	echo -e "--------------------------------------------\n"
 
	if [ $ENABLE_GLOBALS_BACKUPS = "yes" ]
	then
		    echo "Globals backup into '${FINAL_BACKUP_DIR}globals.sql.gz'"
 
		    if ! pg_dumpall -g -h "$HOSTNAME" -U "$USERNAME" | gzip > $FINAL_BACKUP_DIR"globals".sql.gz.in_progress; then
		            echo "[!!ERROR!!] Failed to produce globals backup" 1>&2
		    else
		            mv $FINAL_BACKUP_DIR"globals".sql.gz.in_progress $FINAL_BACKUP_DIR"globals".sql.gz
		    fi
	else
		echo "None"
	fi
 
	###########################
	###### FULL BACKUPS #######
	###########################
 
	FULL_BACKUP_QUERY="select datname from pg_database where not datistemplate and datallowconn order by datname;"
 
	echo -e "\n\nPerforming databases backups"
	echo -e "--------------------------------------------\n"
 
	for DATABASE in `psql -h "$HOSTNAME" -U "$USERNAME" -At -c "$FULL_BACKUP_QUERY" postgres`
	do
		echo "Backing up database '$DATABASE' into '${FINAL_BACKUP_DIR}${DATABASE}.sql.gz'"

		if ! pg_dump -Fp -h "$HOSTNAME" -U "$USERNAME" "$DATABASE" | gzip > $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress; then
			echo "[!!ERROR!!] Failed to produce database backup" 1>&2
		else
			mv $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress $FINAL_BACKUP_DIR"$DATABASE".sql.gz
		fi 
	done
 
	echo -e "\nAll database backups done"
}

if ! mkdir -p $BACKUP_DIR; then
    echo "Cannot create backup directory in $BACKUP_DIR. Go and fix it!" 1>&2
    exit 1;
fi;
 
# MONTHLY BACKUPS
 
DAY_OF_MONTH=`date +%d`
 
if [ $DAY_OF_MONTH -eq $DAY_OF_MONTH_TO_KEEP ];
then
	# Delete all expired monthly directories
	find $BACKUP_DIR -maxdepth 1 -mtime +$MONTHLY_BACKUP_RETENTION_DAYS -name "*-monthly" -exec rm -rf '{}' ';'
 
	perform_backups "-monthly"
 
	exit 0;
fi
 
 
# WEEKLY BACKUPS
 
DAY_OF_WEEK=`date +%u` #1-7 (Monday-Sunday)
 
if [ $DAY_OF_WEEK = $DAY_OF_WEEK_TO_KEEP ];
then
	# Delete all expired weekly directories
	find $BACKUP_DIR -maxdepth 1 -mtime +$WEEKLY_BACKUP_RETENTION_DAYS -name "*-weekly" -exec rm -rf '{}' ';'
 
	perform_backups "-weekly"
 
	exit 0;
fi
 
# DAILY BACKUPS
 
# Delete all expired daily backups
find $BACKUP_DIR -maxdepth 1 -mtime +$DAILY_BACKUP_RETENTION_DAYS -name "*-daily" -exec rm -rf '{}' ';'
 
perform_backups "-daily"
