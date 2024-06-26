#!/bin/bash

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

mysql_src_ip='192.168.100.214'
repl_usr_name='replica'
repl_usr_pass='secret'
bak_usr_name='backup'
bak_usr_pass='secret'
mysqld_cnf_path='/etc/mysql/mysql.conf.d/mysqld.cnf'
mysqld_source_cfg='./config/mysql-src.cnf'
mysqld_replica_cfg='./config/mysql-repl.cnf'
mysqld_err_log_path='/var/log/mysql/error.log'

apt install -yq mysql-server-8.0

systemctl restart mysql.service
! grep -s -e "err" -e "warn" $mysqld_err_log_path

mysql <<EOF
DROP USER IF EXISTS $repl_usr_name@'%';
CREATE USER $repl_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$repl_usr_pass';
GRANT REPLICATION SLAVE ON *.* TO $repl_usr_name@'%';
FLUSH PRIVILEGES;
EOF
echo 'REPLICA USER CREATED!'

mysql <<EOF
DROP USER IF EXISTS $bak_usr_name@'%';
CREATE USER $bak_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$bak_usr_pass';
GRANT ALL ON *.* TO $bak_usr_name@'%'; -- I just don't want to deal with MySQL priviledge system.
FLUSH PRIVILEGES;
EOF
echo 'BACKUP USER CREATED!'

cp "$mysqld_replica_cfg" "$mysqld_cnf_path"
chmod ugo+r "$mysqld_cnf_path"
systemctl restart mysql.service
cat "$mysqld_err_log_path" | grep -s -e "err" -e "warn"

mysql <<EOF
STOP REPLICA;
CHANGE REPLICATION SOURCE TO SOURCE_HOST='192.168.100.214', SOURCE_USER='replica', SOURCE_PASSWORD='secret', SOURCE_AUTO_POSITION = 1, GET_SOURCE_PUBLIC_KEY = 1;
START REPLICA;
SHOW REPLICA STATUS\G
EOF
echo 'REPLICATION STARTED!'

apt -yq install prometheus-node-exporter
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter

cp ./config/db-backup.timer /etc/systemd/system/
cp ./config/db-backup.service /etc/systemd/system/
cp ./config/db-backup.sh /usr/local/bin
systemctl enable --now db-backup.timer
