#!/bin/bash -e

## update
apt update

## metrics
apt install --download-only -y prometheus-node-exporter
## firewall
apt install --download-only -y iptables-persistent
## nfs-client
apt install --download-only -y nfs-common

# reverse proxy
apt install --download-only -y nginx prometheus-nginx-exporter
# web-app
apt install --download-only -y apache2
# db
apt install --download-only -y mysql-server-8.0
# nfs-server
apt install --download-only -y nfs-kernel-server
# elk
apt install --download-only -y default-jdk