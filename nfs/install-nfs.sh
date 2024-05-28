#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

mkdir /mnt/backup-data
mkdir /mnt/backup-data/db-backup
mkdir /mnt/backup-data/tables-backup
chown nobody:nogroup /mnt/backup-data

apt install -yqq nfs-kernel-server > /dev/null

cp ./config/exports /etc/

exportfs -ar

systemctl enable nfs-server
systemctl start nfs-server

apt -yqq install prometheus-node-exporter > /dev/null
systemctl enable --now prometheus-node-exporter

../common/timedate.sh
