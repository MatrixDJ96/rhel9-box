#!/bin/bash

if [[ -n "${container:-}" ]]; then
  sed -i -E 's/^\s*#?\s*enabled\s*=\s*\S+\s*$/enabled=0/' /etc/dnf/plugins/subscription-manager.conf
fi

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

yum config-manager --enable epel

# /usr/bin/crb enable
