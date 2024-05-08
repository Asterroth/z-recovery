#!/bin/bash -e

## metrics
apt-get install --download-only -y prometheus-node-exporter
## firewall
apt-get install --download-only -y iptables-persistent
## nfs-client
apt-get install --download-only -y nfs-common

# reverse proxy
apt-get install --download-only -y nginx prometheus-nginx-exporter
# web-app
apt-get install --download-only -y apache2
# db
apt-get install --download-only -y mysql-server-8.0
# nfs-server
apt-get install --download-only -y nfs-kernel-server
# elk
apt-get install --download-only -y default-jdk