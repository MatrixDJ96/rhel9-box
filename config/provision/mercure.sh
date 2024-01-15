#!/bin/bash

mercure_major_version="0"
mercure_minor_version="18"
mercure_patch_version="4"
mercure_full_version="${mercure_major_version}.${mercure_minor_version}.${mercure_patch_version}"

pkill -u mercure >/dev/null 2>&1 || true
userdel -f mercure >/dev/null 2>&1 || true
groupdel -f mercure >/dev/null 2>&1 || true
useradd -r -M -U -d /var/lib/mercure -s /usr/sbin/nologin mercure
passwd -l mercure >/dev/null 2>&1 || true

rm -f mercure_Linux_x86_64.tar.gz
rm -rf mercure_Linux_x86_64

wget "https://github.com/dunglas/mercure/releases/download/v${mercure_full_version}/mercure_Linux_x86_64.tar.gz"

mkdir -p /var/lib/mercure
mkdir -p /usr/lib/systemd/system
mkdir -p /usr/lib/sysusers.d
mkdir -p /usr/lib/tmpfiles.d
mkdir -p /etc/mercure
mkdir -p /etc/sysconfig

tar -xf "mercure_Linux_x86_64.tar.gz" --directory=/usr/bin mercure
tar -xf "mercure_Linux_x86_64.tar.gz" --directory=/etc/mercure Caddyfile
tar -xf "mercure_Linux_x86_64.tar.gz" --directory=/etc/mercure dev.Caddyfile

cp -f /vagrant/config/mercure/mercure.service /usr/lib/systemd/system/mercure.service
cp -f /vagrant/config/mercure/mercure.sysusers /usr/lib/sysusers.d/mercure.conf
cp -f /vagrant/config/mercure/mercure.tmpfiles /usr/lib/tmpfiles.d/mercure.conf
cp -f /vagrant/config/mercure/environment /etc/sysconfig/mercure

chmod 755 /usr/bin/mercure
chmod 644 /usr/lib/systemd/system/mercure.service
chmod 644 /usr/lib/sysusers.d/mercure.conf
chmod 644 /usr/lib/tmpfiles.d/mercure.conf
chmod 644 /etc/mercure/Caddyfile
chmod 644 /etc/mercure/dev.Caddyfile

chown -R mercure:mercure /var/lib/mercure

rm -f mercure_Linux_x86_64.tar.gz

systemctl daemon-reload
systemctl enable mercure
