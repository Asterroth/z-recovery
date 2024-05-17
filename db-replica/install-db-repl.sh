#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

mysql_src_ip='192.168.1.13'
repl_usr_name='replica'
repl_usr_pass='secret'
bcp_usr_name='backup'
bcp_usr_pass='secret'
mysqld_cnf_path='/etc/mysql/mysql.conf.d/mysqld.cnf'
mysqld_source_cfg='./config/mysql-src.cnf'
mysqld_replica_cfg='./config/msql-repl.cnf'
mysqld_err_log_path='/var/log/mysql/error.log'

fstab_record='192.168.100.188:/mnt/backup-data   /mnt/backup-data   nfs   defaults,timeo=300,retrans=5,_netdev	0 0'

apt install -yq mysql-server-8.0 nfs-common

mkdir /mnt/backup-data
echo $fstab_record >> /etc/fstab
mount 192.168.100.188:/mnt/backup-data /mnt/backup-data/


# Create replica user
mysql <<EOF
DROP USER IF EXISTS $repl_usr_name@'%';
CREATE USER $repl_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$repl_usr_pass';
GRANT REPLICATION SLAVE ON *.* TO $repl_usr_name@'%';
FLUSH PRIVILEGES;
EOF


# Create backup user
mysql <<EOF
DROP USER IF EXISTS $bcp_usr_name@'%';
CREATE USER $bcp_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$bcp_usr_pass';
GRANT ALL ON *.* TO $bcp_usr_name@'%'; -- I just don't want to deal with MySQL priviledge system.
FLUSH PRIVILEGES;
EOF

cp "$mysqld_replica_cfg" "$mysqld_cnf_path"
chmod ugo+r "$mysqld_cnf_path"
systemctl restart mysql.service
cat "$mysqld_err_log_path" | grep -s -e "err" -e "warn"
mysql << EOF
START REPLICA;
SHOW REPLICA STATUS\G
EOF

apt -yq install prometheus-node-exporter
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter

