#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

netplan_conf_dir='/etc/netplan'
netplan_yml='./config/00-balancer-network-config.yaml'
hostname='balancer'

new_ip4rules='./config/balancer-net-rules.sh'
etc_ip4_rules='/etc/iptables/rules.v4'

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt -yqq install iptables-persistent
$new_ip4rules
iptables-save > $etc_ip4_rules

hostname $hostname

apt install -yqq nfs-common
../common/mount-nfs.sh
../common/timedate.sh

[ ! -e $netplan_conf_dir/* ] || rm $netplan_conf_dir/*
cp $netplan_yml $netplan_conf_dir/
echo "*****"
echo "New network configuration applied!"
echo "----------------------------------"
echo "  Please re-connect with new IP!  "

netplan apply

