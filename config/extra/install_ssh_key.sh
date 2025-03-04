#!/bin/bash

config_file="/vagrant/config/tmp_ssh_config"
priv_file="/vagrant/config/tmp_ssh_priv"
pub_file="/vagrant/config/tmp_ssh_pub"

username="vagrant"
ssh_user="$username"

for f in "$config_file" "$priv_file" "$pub_file"; do
  [[ -f $f ]] || { echo "Required file/s not found"; exit 1; }
done

pip3 install -q ssh-config==0.1.6 >/dev/null 2>&1
ln -fs /usr/local/bin/ssh-config /usr/bin/ssh-config

if ! id "$username" >/dev/null 2>&1; then
  ssh_user="root"
fi

echo y | ssh-config -f "$config_file" remove vagrant.local >/dev/null
echo y | ssh-config -f "$config_file" add vagrant.local \
  HostName="127.0.0.1" User="$ssh_user" Port="2222" \
  IdentityFile="~/.ssh/id_vagrant" IdentitiesOnly="yes" \
  StrictHostKeyChecking=no UserKnownHostsFile=/dev/null >/dev/null

sed -i ':a;N;$!ba;s/\nHost/\n\nHost/g' "$config_file"

mkdir -p ~/.ssh && chmod 700 ~/.ssh

declare -A files=(
  ["authorized_keys"]="$pub_file"
  ["config"]="$config_file"
  ["id_vagrant"]="$priv_file"
  ["id_vagrant.pub"]="$pub_file"
)

for name in "${!files[@]}"; do
  install -m 600 "${files[$name]}" ~/.ssh/$name
done

if id "$username" >/dev/null 2>&1; then
  rm -rf "/home/vagrant/.ssh"
  cp -a ~/.ssh "/home/vagrant/.ssh"
  chown -R vagrant:vagrant "/home/vagrant/.ssh"
fi

if [[ "$1" == "--windows" ]]; then
  sed -i 's/UserKnownHostsFile \/dev\/null/UserKnownHostsFile NUL/g' "$config_file"
fi
