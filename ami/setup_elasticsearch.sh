#!/bin/bash

# To be populated after confirming the steps by building the AMI.

# Install AMI tools: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-up-ami-tools.html
sudo yum install -y ruby
wget https://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.noarch.rpm
rpm -K ec2-ami-tools.noarch.rpm
rpm -Kv ec2-ami-tools.noarch.rpm
sudo yum install -y ec2-ami-tools.noarch.rpm
export RUBYLIB=$RUBYLIB:/usr/lib/ruby/site_ruby:/usr/lib64/ruby/site_ruby
echo "The following line should display the installed version of AMI tools"
ec2-ami-tools-version

# Set the following envs so the sudo user has access to the AMI tools
sudo touch /etc/profile.d/ami-tools-env.sh
sudo bash -c 'echo "export RUBYLIB=$RUBYLIB:/usr/lib/ruby/site_ruby:/usr/lib64/ruby/site_ruby" >> /etc/profile.d/ami-tools-env.sh'
sudo bash -c 'echo "export PATH=/usr/local/bin:$PATH:" >> /etc/profile.d/ami-tools-env.sh'

# Install ElasticSearch
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat <<EOF >> elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
sudo mv elasticsearch.repo /etc/yum.repos.d/
sudo yum install -y --enablerepo=elasticsearch elasticsearch
