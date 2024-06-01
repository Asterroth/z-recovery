#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

sites_avail='/etc/nginx/sites-available'
sites_enabl='/etc/nginx/sites-enabled'
nginx_src_proxy_conf='./config/balancer-upstream.conf'
nginx_trg_proxy_conf=$sites_avail/default
nginx_default_conf=$sites_enabl/default

apt install -yq apache2 nfs-common

../common/mount-nfs.sh

cp $nginx_src_proxy_conf $nginx_trg_proxy_conf
chmod ugo+r $nginx_trg_proxy_conf
ln -s -f $nginx_trg_proxy_conf $etc_sites_enabl/

systemctl enable nginx
systemctl restart nginx

apt -yq install prometheus-node-exporter
systemctl enable --now prometheus-node-exporter

dpkg -i /mnt/backup-data/filebeat_8.9.1_amd64-224190-507082.deb
apt --fix-broken -yqq install

cp ./config/filebeat.yml /etc/filebeat/filebeat.yml
chmod ugo+r /etc/filebeat/filebeat.yml

systemctl enable --now filebeat.service
