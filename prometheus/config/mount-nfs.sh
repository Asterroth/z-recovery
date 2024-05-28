#!/bin/bash -e

fstab_record='192.168.100.218:/mnt/backup-data   /mnt/backup-data   nfs   defaults,timeo=300,retrans=5,_netdev	0 0'
mkdir /mnt/backup-data
echo $fstab_record >> /etc/fstab
mount 192.168.100.218:/mnt/backup-data /mnt/backup-data/

echo 'NFS share mounted!'