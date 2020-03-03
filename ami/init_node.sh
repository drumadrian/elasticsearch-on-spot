#!/bin/bash

# Mount the disk
lsblk
sudo mkfs.ext4 /dev/nvme1n1
sudo mkdir /nvmedrivefolder
sudo chmod 775 /nvmedrivefolder
sudo chown ec2-user:ec2-user /nvmedrivefolder
echo "/dev/nvme1n1 /nvmedrivefolder auto noatime 0 0" | sudo tee -a /etc/fstab
sudo mount -a
ls -al /

# Allow elasticsearch user access to the mount drive
sudo chown elasticsearch:elasticsearch /nvmedrivefolder

# We wait till the DNS record is available
masterIP=`getent hosts firstmaster.elasticsearch | awk '{ print $1 }'`
while [ -z $masterIP ] || [ $masterIP = '0.0.0.0' ];
do
  echo "DNS record isn't set for the master node. No ElasticSearch cluster can be formed. Trying again in a min."
  masterIP=`getent hosts firstmaster.elasticsearch | awk '{ print $1 }'`
  sleep 60
done

# We add the master node's IP to the config file
echo " " | sudo tee -a /etc/elasticsearch.elasticsearch.yml # ignore the commented out line
echo "cluster.initial_master_nodes: [\"$masterIP\"]" | sudo tee -a /etc/elasticsearch/elasticsearch.yml

nodeRole=`curl http://169.254.169.254/latest/meta-data/security-groups`

if [ $nodeRole == *"master"* ] || [ $nodeRole == *"Master"* ]; then
  echo "node.master: true" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
  echo "node.data: false" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
elif [ $nodeRole == *"data"* ] || [ $nodeRole == *"Data"* ]; then
  echo "node.master: false" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
  echo "node.data: true" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
fi

# Start ElasticSearch Service
sudo systemctl start elasticsearch.service

# Update Kibana config to point to ElasticSearch
echo "server.host: `curl http://169.254.169.254/latest/meta-data/public-hostname`" | sudo tee -a /etc/kibana/kibana.yml
echo "elasticsearch.hosts: [\"http://$masterIP:9200\"]" | sudo tee -a /etc/kibana/kibana.yml

# Start Kibana Service
if [ $nodeRole == *"master"* ] || [ $nodeRole == *"Master"* ]; then
  sudo systemctl start kibana.service
fi