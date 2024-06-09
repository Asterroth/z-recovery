#!/bin/bash -e

backup_usr_name='backup'
backup_usr_pass='secret'
source_host='192.168.100.214'
mysql_conn="mysql -h $source_host -u$backup_usr_name -p$backup_usr_pass"
db_bak_dir='/mnt/backup-data/db-backup'


# Choose a target sql file name
if [ -e "$1" ]
then
    trg_sql_file="$1"
else
    trg_sql_file=`ls -r -1 -N "$db_bcp_dir"/*.sql.gz | head -n 1`
fi

gunzip -c "$trg_sql_file" | $mysql_conn

echo "$0: restored databases on '$source_host' from '$trg_sql_file'."