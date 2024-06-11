#!/bin/bash -e

mysql_backup_usr_name='backup'
mysql_backup_usr_pass='secret'
#mysql_replica_host='192.168.100.184'
mysql_do="mysql -u$mysql_backup_usr_name -p$mysql_backup_usr_pass --batch --skip-column-names -e "
mysqldump_do="mysqldump -u$mysql_backup_usr_name -p$mysql_backup_usr_pass "
db_bcp_dir='/mnt/backup-data/db-backup'


# Choose a target sql file name
trg_sql_file="$db_bcp_dir/$(date +%Y%m%d_%H%M%S)_MSK.sql"
while [ -e "$trg_sql_file" ]
do
    echo "$0: '$trg_sql_file' is in use. Sleep for 1 second."
    sleep 1
    trg_sql_file="$db_bcp_dir/all_db_on_$(date +%Y%m%d_%H%M%S)_MSK.sql"
done
[ -d  "$db_bcp_dir" ] || mkdir -p "$db_bcp_dir"


# Produce all-user-databases backup
$mysql_do "STOP REPLICA"
$mysql_do  "SELECT db.schema_name AS db FROM information_schema.schemata AS db WHERE db.schema_name NOT IN ('mysql','information_schema','performance_schema','sys')" \
  | xargs $mysqldump_do \
      --source-data=1 \
      --set-gtid-purged=ON \
      --triggers \
      --routines \
      --events \
      --add-drop-database \
      --databases \
      > "$trg_sql_file"
$mysql_do "START REPLICA"


# gzip the sql file
gzip --best "$trg_sql_file"
rm -rf "$trg_sql_file"
chmod 660 "$trg_sql_file.gz"

echo "$0: produced logical backup '$trg_sql_file.gz'."