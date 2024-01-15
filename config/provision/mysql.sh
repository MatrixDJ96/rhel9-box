#!/bin/bash

yum -y install https://dev.mysql.com/get/mysql84-community-release-el9-3.noarch.rpm

yum config-manager --disable mysql80-community
yum config-manager --enable mysql-8.4-lts-community

yum -y install mysql-community-server

install -m 0755 -o root -g root \
  /vagrant/config/mysql/entrypoint.sh \
  /usr/bin/mysqld_pre_systemd

install -D -m 0644 -o root -g root \
  /vagrant/config/mysql/environment \
  /etc/sysconfig/mysql

install -D -m 0644 -o root -g root \
  /vagrant/config/mysql/override.conf \
  /etc/systemd/system/mysqld.service.d/override.conf

# the "socket" value in the Oracle packages is set to "/var/lib/mysql" which isn't a great place for the socket (we want it in "/var/run/mysqld" instead)
# https://github.com/docker-library/mysql/pull/680#issuecomment-636121520
grep -F 'socket=/var/lib/mysql/mysql.sock' /etc/my.cnf
sed -i 's!^socket=.*!socket=/var/run/mysqld/mysqld.sock!' /etc/my.cnf
grep -F 'socket=/var/run/mysqld/mysqld.sock' /etc/my.cnf
{ echo '[client]'; echo 'socket=/var/run/mysqld/mysqld.sock'; } >> /etc/my.cnf

# make sure users dumping files in "/etc/mysql/conf.d" still works
! grep -F '!includedir' /etc/my.cnf
{ echo; echo '!includedir /etc/mysql/conf.d/'; } >> /etc/my.cnf
mkdir -p /etc/mysql/conf.d

# ensure these directories exist and have useful permissions
# the rpm package has different opinions on the mode of `/var/run/mysqld`, so this needs to be after install
mkdir -p /var/lib/mysql /var/run/mysqld
chown mysql:mysql /var/lib/mysql /var/run/mysqld

# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
chmod 1777 /var/lib/mysql /var/run/mysqld

systemctl enable mysqld
