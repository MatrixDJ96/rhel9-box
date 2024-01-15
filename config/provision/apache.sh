#!/bin/bash

yum -y install httpd mod_ssl

sed -i '/IncludeOptional \/vagrant\/config\/apache.*$/d' /etc/httpd/conf/httpd.conf
echo "IncludeOptional /vagrant/config/apache/*.conf" >>/etc/httpd/conf/httpd.conf

systemctl enable httpd
