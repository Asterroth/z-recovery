#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

fstab_record='192.168.100.218:/mnt/backup-data   /mnt/backup-data   nfs   defaults,timeo=300,retrans=5,_netdev	0 0'

if [ ! -d /mnt/backup-data ]
then
    mkdir /mnt/backup-data
fi

echo $fstab_record >> /etc/fstab
mount 192.168.100.218:/mnt/backup-data /mnt/backup-data/
