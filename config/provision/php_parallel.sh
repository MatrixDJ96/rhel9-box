#!/bin/bash

parallel_major_version="1"
parallel_minor_version="2"
parallel_patch_version="8"
parallel_full_version="${parallel_major_version}.${parallel_minor_version}.${parallel_patch_version}"

post_install() {
  tar -xvf parallel-${parallel_full_version}.tgz
  cd parallel-${parallel_full_version}

  if [[ "${2}" == "" ]]; then
    cp -f /vagrant/config/php/30-parallel.ini /etc/opt/remi/${1}/php.d/30-parallel.ini
    chmod 644 /etc/opt/remi/${1}/php.d/30-parallel.ini

    ${1}-phpize
    ./configure --with-php-config=$(which ${1}-config)
  else
    cp -f /vagrant/config/php/30-parallel.ini /etc/${1}.d/30-parallel.ini
    chmod 644 /etc/${1}.d/30-parallel.ini

    ${2}ize
    ./configure --with-php-config=$(which ${2}-config)
  fi

  make && make install

  cd ..
  rm -f package.xml
  rm -rf parallel-${parallel_full_version}
}

wget http://pecl.php.net/get/parallel-${parallel_full_version}.tgz

post_install php-zts zts-php

rm -f parallel-${parallel_full_version}.tgz
