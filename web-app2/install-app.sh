#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

html_path='/var/www/html'
ports_conf_dir='/etc/apache2'
ports_conf='/etc/apache2/ports.conf'
default_conf_dir='/etc/apache2/sites-enabled'
default_conf='/etc/apache2/sites-enabled/000-default.conf'

apt install -yq apache2

rm -f $html_path/index.html
cp ./config/index2.html $html_path/index.html

mv $ports_conf $ports_conf_dir/ports.conf.original
cp ./config/ports2.conf $ports_conf

mv $default_conf $default_conf_dir/000-default.conf.original
cp ./config/000-default2.conf $default_conf_dir/000-default.conf

systemctl start apache2
systemctl enable apache2

apt -yq install prometheus-node-exporter
systemctl enable --now prometheus-node-exporter
