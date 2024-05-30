#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

downloader='./config/packages-downloader.sh'
netplan_conf_dir='/etc/netplan'
netplan_yaml='./config/99-basic-network-config.yaml'
hostname='basic'

$downloader
[ ! -e $netplan_conf_dir/* ] || rm $netplan_conf_dir/*
cp $netplan_yaml $netplan_conf_dir/

hostname $hostname

cat 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config

timedatectl set-timezone Europe/Moscow
timedatectl set-ntp true
netplan apply
echo "*****"
echo "New network configuration applied!"
echo "----------------------------------"
echo "  Please re-connect with new IP!  "
