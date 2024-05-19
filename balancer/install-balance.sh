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
# prometheus-nginx-exporter
####ng_exp_sysd_trg='/lib/systemd/system/prometheus-nginx-exporter.service'
####ng_exp_sysd_src='./prometheus-nginx-exporter-cfg/prometheus-nginx-exporter.service'
# iptables
###new_ip4rules='./config/balancer-net-rules.sh'
###ip4_rules='/etc/iptables/rules.v4'


# Install nginx
fstab_record='192.168.100.188:/mnt/backup-data   /mnt/backup-data   nfs   defaults,timeo=300,retrans=5,_netdev	0 0'

apt install -yq nginx nfs-common

mkdir /mnt/backup-data
echo $fstab_record >> /etc/fstab
mount 192.168.100.188:/mnt/backup-data /mnt/backup-data/

cp $nginx_src_proxy_conf $nginx_trg_proxy_conf
chmod ugo+r $nginx_trg_proxy_conf
ln -s -f $nginx_trg_proxy_conf $etc_sites_enabl/
#[ ! -L $nginx_default_conf ] || rm -f $nginx_default_conf

systemctl enable nginx
systemctl restart nginx

apt -yq install prometheus-node-exporter
systemctl enable --now prometheus-node-exporter


