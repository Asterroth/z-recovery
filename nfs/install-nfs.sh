#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

mkdir /mnt/backup-data
chown nobody:nogroup /mnt/backup-data
mkdir /mnt/backup-data/db-backup
mkdir /mnt/backup-data/tables-backup

apt install -yq nfs-kernel-server

cp ./config/exports /etc/

exportfs -ar

systemctl enable nfs-server
systemctl start nfs-server