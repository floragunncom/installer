#!/bin/bash
set +e
sudo killall java > /dev/null 2>&1
sudo apt-get purge -y elasticsearch > /dev/null 2>&1
sudo rm -rf /etc/elasticsearch > /dev/null 2>&1
sudo rm -rf /var/lib/elasticsearch > /dev/null 2>&1
sudo rm -rf /usr/share/elasticsearch > /dev/null 2>&1
sudo rm -rf /var/log/elasticsearch > /dev/null 2>&1
set -e
echo "Process $1"
bash <(curl -s https://raw.githubusercontent.com/floragunncom/installer/next/helpers/esinstall.sh) "$1"
bash <(curl -s https://raw.githubusercontent.com/floragunncom/installer/next/sginstall.sh) -d -v -c -s
sudo sed -i -e 's/network.host: 0.0.0.0/network.host: localhost/g' /etc/elasticsearch/elasticsearch.yml
bash <(curl -s https://raw.githubusercontent.com/floragunncom/installer/next/helpers/esrestart.sh)
sleep 30
./sgadmin_demo.sh
#sudo ls -la /etc/elasticsearch
#sudo cat /etc/elasticsearch/elasticsearch.yml
curl -k -u admin:admin https://localhost:9200/_searchguard/authinfo?pretty
curl -k -u admin:admin https://localhost:9200/_searchguard/sslinfo?pretty
curl -k -u admin:admin https://localhost:9200/_cluster/health?pretty
echo "Kill elasticsearch"
sudo killall java
#sudo ls -la /var/log/elasticsearch
sudo cat /var/log/elasticsearch/searchguard_demo.log
echo "Done"