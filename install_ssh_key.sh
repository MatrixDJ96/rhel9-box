#!/bin/bash

cd $(dirname $0)

echo Installing ssh key...

touch ~/.ssh/config &&
  ([ -f ~/.ssh/id_vagrant ] || ssh-keygen -q -t rsa -b 4096 -C "vagrant" -P "" -f ~/.ssh/id_vagrant) &&
  cp -f ~/.ssh/config config/tmp_ssh_config &&
  cp -f ~/.ssh/id_vagrant config/tmp_ssh_priv &&
  cp -f ~/.ssh/id_vagrant.pub config/tmp_ssh_pub &&
  docker exec rhel9 /vagrant/config/extra/install_ssh_key.sh &&
  cp -f config/tmp_ssh_config ~/.ssh/config &&
  rm -f config/tmp_ssh_config &&
  rm -f config/tmp_ssh_priv &&
  rm -f config/tmp_ssh_pub

echo Done
