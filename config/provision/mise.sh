#!/bin/bash

yum config-manager --add-repo https://mise.jdx.dev/rpm/mise.repo

yum -y install mise

mkdir -p /opt/mise
mkdir -p /etc/mise

echo 'eval "$(mise activate bash)"' >/etc/profile.d/mise.sh
echo 'export MISE_DATA_DIR=/opt/mise' >>/etc/profile.d/mise.sh

echo "[settings]" >/etc/mise/config.toml
echo "idiomatic_version_file_enable_tools = ['node']" >>/etc/mise/config.toml
