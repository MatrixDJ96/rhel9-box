#!/bin/bash

php_pkgs=(
  "fpm"
  "apcu"
  "devel"
  "gd"
  "gmp"
  "imap"
  "intl"
  "ldap"
  "mailparse"
  "mbstring"
  "mysqli"
  "pdo"
  "opcache"
  "pear"
  "sodium"
  "ssh2"
  "soap"
  "xdebug"
  "xml"
  "zip"
  "bcmath"
)

get_php_pkgs() {
  local result="${1}"

  for php_pkg in "${php_pkgs[@]}"; do
    result+=" ${1}-${php_pkg}"
  done

  result+=" -x php-fedora-autoloader"

  echo "${result}"
}

yum -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm

yum -y module reset php

yum -y install $(get_php_pkgs php74-php)
yum -y install $(get_php_pkgs php80-php)
yum -y install $(get_php_pkgs php81-php)
yum -y install $(get_php_pkgs php82-php)
yum -y install $(get_php_pkgs php83-php)
yum -y install $(get_php_pkgs php84-php)

post_install() {
  rm -f /etc/httpd/conf.d/${1}-php.conf

  ln -fs /opt/remi/${1}/root/usr/bin/pear /bin/${1}-pear
  ln -fs /opt/remi/${1}/root/usr/bin/pecl /bin/${1}-pecl
  ln -fs /opt/remi/${1}/root/usr/bin/phpize /bin/${1}-phpize
  ln -fs /opt/remi/${1}/root/usr/bin/php-config /bin/${1}-config

  install -D -m 0644 -o root -g root \
    /vagrant/config/php/15-xdebug.ini \
    /etc/opt/remi/${1}/php.d/15-xdebug.ini

  sed -ri \
    -e 's/^\s*;?\s*memory_limit.*/memory_limit = -1/' \
    -e 's/^\s*;?\s*max_execution_time.*/max_execution_time = 900/' \
    -e 's/^\s*;?\s*max_input_time.*/max_input_time = 900/' \
    -e 's/^\s*;?\s*post_max_size.*/post_max_size = 50M/' \
    -e 's/^\s*;?\s*short_open_tag.*/short_open_tag = On/' \
    -e 's/^\s*;?\s*upload_max_filesize.*/upload_max_filesize = 50M/' \
    "/etc/opt/remi/${1}/php.ini"

  sed -ri \
    -e 's/^\s*;?\s*clear_env.*/clear_env = no/' \
    "/etc/opt/remi/${1}/php-fpm.d/www.conf"

  sed -ri \
    -e 's/^\s*;?\s*user.*/user = root/' \
    -e 's/^\s*;?\s*group.*/group = root/' \
    "/etc/opt/remi/${1}/php-fpm.d/www.conf"

  install -D -m 0644 -o root -g root \
    /vagrant/config/php-fpm/override.conf \
    /etc/systemd/system/${1}-php-fpm.service.d/override.conf

  sed -i "s/PHP_VERSION/${1}/" \
    /etc/systemd/system/${1}-php-fpm.service.d/override.conf
}

post_install php74
post_install php80
post_install php81
post_install php82
post_install php83
post_install php84

systemctl daemon-reload

systemctl enable php74-php-fpm
systemctl enable php80-php-fpm
systemctl enable php81-php-fpm
systemctl enable php82-php-fpm
systemctl enable php83-php-fpm
systemctl enable php84-php-fpm
