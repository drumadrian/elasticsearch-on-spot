sudo yum update -y 

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html
sudo yum install -y awslogs
sudo service awslogsd start
sudo systemctl enable awslogsd.service
sudo service awslogsd start

# Edit file /etc/awslogs/awscli.conf and change your AWS Region.
# Edit file /etc/awslogs/awslogs.conf and verify following lines

# https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-manual-agent-install.html#agent-install-al
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl status amazon-ssm-agent
sudo chmod -R 777 /etc/awslogs/
sudo chown -R ec2-user:ec2-user /etc/awslogs
