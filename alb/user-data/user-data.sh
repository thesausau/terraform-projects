#!/bin/bash
apt-get update
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
PRIVATE_IP=$(hostname -I | awk '{print $1}')
echo "Hello World" > /var/www/html/index.html
echo "Private IP: $PRIVATE_IP" >> /var/www/html/index.html