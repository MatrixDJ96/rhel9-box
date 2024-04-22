#!/bin/bash

tomcat_major_version="9"
tomcat_minor_version="0"
tomcat_patch_version="107"
tomcat_full_version="${tomcat_major_version}.${tomcat_minor_version}.${tomcat_patch_version}"

JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/jre-11}"

pkill -u tomcat >/dev/null 2>&1 || true
userdel -f tomcat >/dev/null 2>&1 || true
groupdel -f tomcat >/dev/null 2>&1 || true
useradd -r -M -U -d /opt/tomcat -s /usr/sbin/nologin tomcat
passwd -l tomcat >/dev/null 2>&1 || true

rm -f apache-tomcat-${tomcat_full_version}.tar.gz
rm -rf apache-tomcat-${tomcat_full_version}

wget https://archive.apache.org/dist/tomcat/tomcat-${tomcat_major_version}/v${tomcat_full_version}/bin/apache-tomcat-${tomcat_full_version}.tar.gz

mkdir -p /usr/lib/systemd/system
mkdir -p /opt/tomcat/latest
mkdir -p /etc/sysconfig

rm -rf /opt/tomcat/backup

if [ -d /opt/tomcat/latest ]; then
  mv /opt/tomcat/latest /opt/tomcat/backup
fi

tar -xf apache-tomcat-${tomcat_full_version}.tar.gz
mv apache-tomcat-${tomcat_full_version} /opt/tomcat/latest

cp -f /vagrant/config/tomcat/tomcat.service /usr/lib/systemd/system/tomcat.service
cp -f /vagrant/config/tomcat/setenv.sh /opt/tomcat/latest/bin/setenv.sh
cp -f /vagrant/config/tomcat/tomcat-users.xml /opt/tomcat/latest/conf/tomcat-users.xml
cp -f /vagrant/config/tomcat/context.xml /opt/tomcat/latest/webapps/manager/META-INF/context.xml
cp -f /vagrant/config/tomcat/context.xml /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml
cp -f /vagrant/config/tomcat/environment /etc/sysconfig/tomcat

sed -i -E "s|(JAVA_HOME=).*|\1${JAVA_HOME}|" /etc/sysconfig/tomcat

chmod 644 /usr/lib/systemd/system/tomcat.service
chmod 755 /opt/tomcat/latest/bin/setenv.sh
chmod 600 /opt/tomcat/latest/conf/tomcat-users.xml
chmod 640 /opt/tomcat/latest/webapps/manager/META-INF/context.xml
chmod 640 /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml

rm -f apache-tomcat-${tomcat_full_version}.tar.gz

if [ -d /opt/tomcat/backup/webapps ]; then
  default=(docs examples host-manager manager ROOT)

  for path in /opt/tomcat/backup/webapps/*; do
    file=$(basename "$path")

    for i in "${default[@]}"; do
      if [ "$file" == "$i" ]; then
        continue 2
      fi
    done

    mv "$path" "/opt/tomcat/latest/webapps/$file"
  done

  rm -rf /opt/tomcat/backup
fi

chown -R tomcat:tomcat /opt/tomcat
chmod +x /opt/tomcat/latest/bin/*.sh

systemctl daemon-reload
systemctl enable tomcat
