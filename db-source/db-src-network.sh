#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi


# netplan
netplan_etc_dir='/etc/netplan'
netplan_src_path='./config/00-db-src-config.yaml'
netplan_cfg_name='00-db-src-config.yaml'
hostname='db-src'

new_ip4rules='./config/db-src-net-rules.sh'
etc_ip4_rules='/etc/iptables/rules.v4'

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt -yq install iptables-persistent
$new_ip4rules
iptables-save > $etc_ip4_rules


# Update network settings
echo $hostname > /etc/hostname
hostname $hostname
rm $netplan_etc_dir/* || true
cp $netplan_src_path $netplan_etc_dir/$netplan_cfg_name
echo "*****"
echo "New network configuration applied!"
echo "----------------------------------"
echo "  Please re-connect with new IP!  "
netplan apply