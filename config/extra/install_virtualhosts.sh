#!/bin/bash

linux_host="/etc/hosts"
windows_host="/vagrant/config/tmp_host"

if [ "$(whoami)" == "root" ]; then
  (test -f "$linux_host" && test -f "$windows_host") || (echo "Required file/s not found" && exit 1)

  sed -i 's/\r//g' "$windows_host"

  sed -i "/.*vagrant.local.*/d" "$windows_host"
  echo "127.0.0.1 vagrant.local" >>"$windows_host"

  for path in /vagrant/config/apache/*.conf; do
    test -f "$path" || continue

    file=$(basename "$path")
    host=$(sed 's/\r//g' "$path" | grep 'ServerName' | grep -v '#' | awk '{print $2}')

    if [ "$file" != "" ]; then
      if [ "$host" != "" ] && [ "$host" != "localhost" ]; then
        if [[ -z "$container" ]]; then
          sed -i "/[[:space:]]\+$host\b/d" "$linux_host"
          echo "127.0.0.1 $host" >>"$linux_host"
        fi

        sed -i "/[[:space:]]\+$host\b/d" "$windows_host"
        echo "127.0.0.1 $host" >>"$windows_host"

        echo "Applied virtual host '$host'"
      fi
    fi
  done

  sed -i 's/$/\r/' "$windows_host"

  systemctl stop httpd && systemctl start httpd
else
  echo 'Please run as root'
fi
