#!/bin/bash

MYSQL_VERSION="${MYSQL_VERSION:-8.4}"

yum -y install "https://dev.mysql.com/get/mysql${MYSQL_VERSION//./}-community-release-el9.rpm"

# the release package enables its own LTS series: keep only the wanted one
yum config-manager --disable 'mysql*'
yum config-manager --enable \
  "mysql-${MYSQL_VERSION}-lts-community" \
  "mysql-tools-${MYSQL_VERSION}-lts-community" \
  mysql-connectors-community

yum -y install mysql-community-server

# fail on any series but the wanted one
INSTALLED_VERSION="$(rpm -q --queryformat '%{VERSION}' mysql-community-server)"
if [[ "${INSTALLED_VERSION}" != "${MYSQL_VERSION}."* ]]; then
  echo "MySQL ${MYSQL_VERSION} expected, ${INSTALLED_VERSION} installed" >&2
  exit 1
fi

install -m 0755 -o root -g root \
  /vagrant/config/mysql/entrypoint.sh \
  /usr/bin/mysqld_pre_systemd

install -D -m 0644 -o root -g root \
  /vagrant/config/mysql/environment \
  /etc/sysconfig/mysql

install -D -m 0644 -o root -g root \
  /vagrant/config/mysql/override.conf \
  /etc/systemd/system/mysqld.service.d/override.conf

install -D -m 0644 -o root -g root \
  /vagrant/config/mysql/disable-binlog.cnf \
  /etc/mysql/conf.d/disable-binlog.cnf

# the "socket" value in the Oracle packages is set to "/var/lib/mysql" which isn't a great place for the socket (we want it in "/var/run/mysqld" instead)
# https://github.com/docker-library/mysql/pull/680#issuecomment-636121520
sed -i 's!^socket=.*!socket=/var/run/mysqld/mysqld.sock!' /etc/my.cnf
grep -F 'socket=/var/run/mysqld/mysqld.sock' /etc/my.cnf
if ! grep -qF '[client]' /etc/my.cnf; then
  { echo '[client]'; echo 'socket=/var/run/mysqld/mysqld.sock'; } >> /etc/my.cnf
fi

# make sure users dumping files in "/etc/mysql/conf.d" still works
if ! grep -qF '!includedir' /etc/my.cnf; then
  { echo; echo '!includedir /etc/mysql/conf.d/'; } >> /etc/my.cnf
fi
mkdir -p /etc/mysql/conf.d

# ensure these directories exist and have useful permissions
# the rpm package has different opinions on the mode of `/var/run/mysqld`, so this needs to be after install
mkdir -p /var/lib/mysql /var/run/mysqld
chown mysql:mysql /var/lib/mysql /var/run/mysqld

# the data directory and /var/run/mysqld (socket and lock files) stay writable whatever UID mysqld runs as
chmod 1777 /var/lib/mysql /var/run/mysqld

systemctl enable mysqld
