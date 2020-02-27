#!/bin/bash
# ENVs - To be configured later to be sourced.
export AWS_ACCESS_KEY_ID="ASIARPNTYT6T4EMCJAAH"
export AWS_SECRET_ACCESS_KEY="x3A9qsWLo1yvaySirSzlzSJNq1m+I1jgt/sbHDM0"
export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEOT//////////wEaCXVzLXdlc3QtMiJIMEYCIQCURjGiH74R444XRCgMUyKf6uPRQ64CprU0jdlzYVUWdgIhAL3bfFvjhnnuB1pSzqIjydwjomvESSM1tz8wOBTGZ57kKpACCKz//////////wEQAhoMMTAxODQ1NjA2MzExIgyj9n0xLoC6IeYhQ5Uq5AG1GdB4VYtnjp+xoB0kf24JEg37CPfXbkmI5sJUjRTLov3w0sZ660ZMpmPKrXPkxyho+3aUU7uwq80c817kX8gyTj76mtgeHWM+xjDtheuFEpwiReQndbdJZafzsSaiYFLdraCnyHytKHCg3KcBIuF49WRRQbZdCH0wduBL/iJFhJu8z0kT4eG6MQmmeCTs4G/9qW/uUr/1oVGWpqQQ0xs7373cAKnWKNW/1hO8OmQopxa4y3Cl/bn98uMhKZC4O/gjhNUfCRlL8k1dVvoojh9KES5mf/43D7m7h5gzGzqQvapJhUEwuYnb8gU66AFXFZAfsFnDqeKfuYYSb+g5Bp+65ZyE5bWjiGGZY6c/1hi7PJ26ibjs6ZxYENPMnlTzLo+wLPu980obG9BJB/VLr+BV/rcABbjaZZFtsc2dAVKF/SIk3Q2Uw19MaY6VHLMgb155DRvcehfgxAjfuGHX+IebxZFx8v5aILDqPi7pNVqLktDD7qlOmhxJS1O8y6JrVHgLnxhU1UUx+5mVz91wQTGCJiazu90n8ygegbtbrEzDfrkl3UVWdRvcvkaX6NlHLk/7f74D7FxOKHPM2uXX0EIDMWfinbcAXBElvWu4FpIJSHTrHpsi"
export AWS_DEFAULT_REGION=us-west-2

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

# DNS record is set manually and then the first node is restarted.
masterIP=`getent hosts firstmaster.sid.elasticsearch | awk '{ print $1 }'`
if [ -z $masterIP ]
then
  echo "DNS record isn't set for the master node. No ElasticSearch cluster can be formed."
  exit 1
else
  echo "cluster.initial_master_nodes: [\"`getent hosts firstmaster.sid.elasticsearch | awk '{ print $1 }'`\"]" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
fi

nodeRole=`curl http://169.254.169.254/latest/meta-data/security-groups`

if [[ $nodeRole == *"master"* ]]; then
  echo "node.master: true" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
  echo "node.data: false" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
elif [[ $nodeRole == *"data"* ]]; then
  echo "node.master: false" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
  echo "node.data: true" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
fi

# Start ElasticSearch Service
sudo systemctl start elasticsearch.service

if [[ $nodeRole == *"master"* ]]; then
  sudo systemctl start kibana.service
fi