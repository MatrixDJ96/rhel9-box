#!/bin/bash

keycloak_major_version="26"
keycloak_minor_version="1"
keycloak_patch_version="5"
keycloak_full_version="${keycloak_major_version}.${keycloak_minor_version}.${keycloak_patch_version}"

JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/jre-21}"

pkill -u keycloak >/dev/null 2>&1 || true
userdel -f keycloak >/dev/null 2>&1 || true
groupdel -f keycloak >/dev/null 2>&1 || true
useradd -r -M -U -d /opt/keycloak -s /usr/sbin/nologin keycloak
passwd -l keycloak >/dev/null 2>&1 || true

rm -f keycloak-${keycloak_full_version}.tar.gz
rm -rf keycloak-${keycloak_full_version}

wget https://github.com/keycloak/keycloak/releases/download/${keycloak_full_version}/keycloak-${keycloak_full_version}.tar.gz
# wget https://github.com/keycloak/keycloak/archive/${keycloak_full_version}/keycloak-${keycloak_full_version}.tar.gz

mkdir -p /usr/lib/systemd/system
mkdir -p /usr/lib/sysusers.d
mkdir -p /usr/lib/tmpfiles.d
mkdir -p /opt/keycloak/latest

rm -rf /opt/keycloak/backup

if [ -d /opt/keycloak/latest ]; then
  mv /opt/keycloak/latest /opt/keycloak/backup
fi

tar -xf keycloak-${keycloak_full_version}.tar.gz
mv keycloak-${keycloak_full_version} /opt/keycloak/latest

if [ -d /opt/keycloak/backup ]; then
  cp -f -u /opt/keycloak/backup/providers/* /opt/keycloak/latest/providers
  cp -f -u /opt/keycloak/backup/conf/keycloak.conf /opt/keycloak/latest/conf/keycloak.conf
fi

cp -f /vagrant/config/keycloak/keycloak.service /usr/lib/systemd/system/keycloak.service
cp -f /vagrant/config/keycloak/keycloak.sysusers /usr/lib/sysusers.d/keycloak.conf
cp -f /vagrant/config/keycloak/keycloak.tmpfiles /usr/lib/tmpfiles.d/keycloak.conf
cp -f /vagrant/config/keycloak/keycloak-bcrypt-1.6.0.jar /opt/keycloak/latest/providers/keycloak-bcrypt-1.6.0.jar
cp -f /vagrant/config/keycloak/environment /etc/sysconfig/keycloak

sed -i -E "s|(JAVA_HOME=).*|\1${JAVA_HOME}|" /etc/sysconfig/keycloak

chmod 644 /usr/lib/systemd/system/keycloak.service
chmod 644 /usr/lib/sysusers.d/keycloak.conf
chmod 644 /usr/lib/tmpfiles.d/keycloak.conf
chmod 644 /opt/keycloak/latest/conf/keycloak.conf
chmod 644 /opt/keycloak/latest/providers/keycloak-bcrypt-1.6.0.jar

rm -f keycloak-${keycloak_full_version}.tar.gz

chown -R keycloak:keycloak /opt/keycloak
chmod +x /opt/keycloak/latest/bin/*.sh

systemctl daemon-reload
systemctl enable keycloak
