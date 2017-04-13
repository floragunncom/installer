#!/bin/bash
set -e
echo "Process $1"
bash <(curl -s https://raw.githubusercontent.com/floragunncom/installer/next/helpers/esinstall.sh) "$1"
bash <(curl -s https://raw.githubusercontent.com/floragunncom/installer/next/sginstall.sh) -d -v -c -s
sudo sed -i -e 's/network.host: 0.0.0.0/network.host: localhost/g' /etc/elasticsearch/elasticsearch.yml
bash <(curl -s https://raw.githubusercontent.com/floragunncom/installer/next/helpers/esrestart.sh)
sleep 30
./sgadmin_demo.sh
#sudo ls -la /etc/elasticsearch
sudo ls -la /var/log/elasticsearch
#sudo cat /etc/elasticsearch/elasticsearch.yml
curl -k -u admin:admin https://localhost:9200/_searchguard/authinfo?pretty
curl -k -u admin:admin https://localhost:9200/_searchguard/sslinfo?pretty
curl -k -u admin:admin https://localhost:9200/_cluster/health?pretty
sudo killall java
sudo cat /var/log/elasticsearch/*
sudo apt-get purge -f -y elasticsearch 