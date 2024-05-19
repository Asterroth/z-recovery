#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

timedatectl set-timezone Europe/Moscow
timedatectl set-ntp true