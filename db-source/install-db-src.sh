#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

# mysql-source
repl_usr_name='replica'
repl_usr_pass='secret'
bak_usr_name='backup'
bak_usr_pass='secret'
app_usr_name='wordpress_user'
app_usr_pass='secret'
app_db_name='app_db'
mysqld_cnf_path='/etc/mysql/mysql.conf.d/mysqld.cnf'
mysqld_new_cfg='./config/mysql-src.cnf'
mysqld_err_log_path='/var/log/mysql/error.log'


# Install nginx
fstab_record='192.168.100.188:/mnt/backup-data   /mnt/backup-data   nfs   defaults,timeo=300,retrans=5,_netdev	0 0'

apt-get install -yq mysql-server-8.0 nfs-common

mkdir /mnt/backup-data
echo $fstab_record >> /etc/fstab
mount 192.168.100.188:/mnt/backup-data /mnt/backup-data/

cp $mysqld_new_cfg $mysqld_cnf_path
chmod ugo+r "$mysqld_cnf_path"

systemctl restart mysql.service
! grep -s -e "err" -e "warn" $mysqld_err_log_path

# Create replica user
mysql <<EOF
DROP USER IF EXISTS $repl_usr_name@'%';
CREATE USER $repl_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$repl_usr_pass';
GRANT REPLICATION SLAVE ON *.* TO $repl_usr_name@'%';
EOF


# Create backup user
mysql <<EOF
DROP USER IF EXISTS $bak_usr_name@'%';
CREATE USER $bak_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$bak_usr_pass';
GRANT ALL ON *.* TO $bak_usr_name@'%'; -- I just don't want to deal with MySQL priviledge system.
EOF


# Create app database
mysql <<EOF
CREATE DATABASE IF NOT EXISTS $app_db_name
    CHARACTER SET = utf8mb4
    COLLATE = utf8mb4_general_ci
;
EOF


# Create app user
mysql <<EOF
CREATE USER IF NOT EXISTS $app_usr_name@'%' IDENTIFIED WITH 'sha256_password' BY '$app_usr_pass'
    -- 'caching_sha2_password' BY '$app_usr_pass' -- wp-php-apache-node doesnot support this method
;
GRANT ALL PRIVILEGES ON $app_db_name.* TO $app_usr_name@'%'
;
EOF


# Install and run prometheus node exporter
apt -yq install prometheus-node-exporter
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter