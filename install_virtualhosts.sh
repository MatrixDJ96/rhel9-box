#!/bin/bash

cd $(dirname $0)

source config/extra/engine.sh

echo Installing virtual hosts...

sudo cp -f /etc/hosts config/tmp_host &&
  "${ENGINE}" exec rhel9 /vagrant/config/extra/install_virtualhosts.sh &&
  sed -i 's/\r//g' config/tmp_host &&
  sudo cp -f config/tmp_host /etc/hosts &&
  rm -f config/tmp_host

echo Done
