#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

dpkg -i /mnt/backup-data/elasticsearch_8.9.1_amd64-224190-ed0378.deb
dpkg -i /mnt/backup-data/kibana_8.9.1_amd64-224190-939c28.deb
dpkg -i /mnt/backup-data/logstash_8.9.1_amd64-224190-d5e2e9.deb

cp ./config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
chmod ugo+r /etc/elasticsearch/elasticsearch.yml
cp ./config/jvm.options /etc/elasticsearch/jvm.options.d/jvm.options
cp ./config/kibana.yml /etc/kibana/kibana.yml
chmod ugo+r /etc/kibana/kibana.yml
cp ./config/logstash.yml /etc/logstash/logstash.yml
chmod ugo+r /etc/logstash/logstash.yml
cp ./config/logstash-nginx-es.conf /etc/logstash/conf.d/

apt install -yqq prometheus-node-exporter

systemctl enable --now prometheus-node-exporter

systemctl enable --now elasticsearch
systemctl enable --now kibana
systemctl enable --now logstash
