#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

apt install -yqq prometheus prometheus-node-exporter nfs-common

cp ./config/prometheus.yml /etc/prometheus/

systemctl enable --now prometheus
systemctl enable --now prometheus-node-exporter

apt install -yqq adduser libfontconfig1 musl > /dev/null
dpkg -i /mnt/backup-data/grafana_10.4.1_amd64.deb

systemctl enable --now grafana-server
