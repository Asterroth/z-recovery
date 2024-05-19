#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

apt install -yqq prometheus prometheus-node-exporter > /dev/null

#../common/mount-nfs.sh
#fstab_record='192.168.100.188:/mnt/backup-data   /mnt/backup-data   nfs   defaults,timeo=300,retrans=5,_netdev	0 0'
#mkdir /mnt/backup-data
#echo $fstab_record >> /etc/fstab
#mount 192.168.100.188:/mnt/backup-data /mnt/backup-data/

../common/timedate.sh

cp ./config/prometheus.yml /etc/prometheus/

systemctl enable --now prometheus
systemctl enable --now prometheus-node-exporter

apt install -yqq adduser libfontconfig1 musl > /dev/null
dpkg -i ./grafana_10.4.1_amd64

systemctl enable --now grafana-server
