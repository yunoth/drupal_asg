#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#sudo yum update -y
sudo systemctl restart amazon-ssm-agent
#sudo yum install -y php
sudo amazon-linux-extras install -y php7.2
sudo yum install -y httpd.x86_64 php-dom php-gd php-simplexml php-xml php-opcache php-mbstring amazon-efs-utils
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm
json='{ "metrics":{ "metrics_collected":{ "mem":{ "measurement":[ "mem_used_percent" ], "metrics_collection_interval":30 } } } }'
echo $json > /opt/aws/amazon-cloudwatch-agent/bin/config.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
sudo mount -t nfs4 -o nfsvers=4.1 ${efs_target}:/ /var/www/html/
if [ ! -f /var/www/html/index.html ]; then
    echo "File not found!"
    echo “Hello from $(hostname -f)” > /var/www/html/index.html
    chown apache:apache /var/www/html/index.html
    cd /var/www/html/
    wget https://ftp.drupal.org/files/projects/drupal-8.9.20.tar.gz
    tar -xvf drupal-8.9.20.tar.gz
    ln -s drupal-8.9.20 drupal
    chown -R apache:apache /var/www/html/
fi
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
