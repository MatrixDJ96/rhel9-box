#!/bin/bash

cd $(dirname $0)

echo Installing virtual hosts...

sudo cp -f /etc/hosts config/tmp_host &&
  docker exec rhel9 /vagrant/config/extra/install_virtualhosts.sh &&
  sed -i 's/\r//g' config/tmp_host &&
  sudo cp -f config/tmp_host /etc/hosts &&
  rm -f config/tmp_host

echo Done
