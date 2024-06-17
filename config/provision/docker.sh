#!/bin/bash

if [ "$1" = "--ubuntu" ]; then
  apt-get update
  apt-get install -y ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt-get update

  apt-get install -y podman docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  yum config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

  yum -y install \
    podman \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
fi

systemctl disable --now docker.socket
systemctl disable --now docker.service

mkdir -p /etc/tmpfiles.d
install -Dm644 /dev/stdin /etc/tmpfiles.d/docker.conf <<'EOF'
L+ /run/docker.sock - - - - /run/podman/podman.sock
EOF

systemctl enable --now podman.socket
systemctl --global enable podman.socket

systemd-tmpfiles --create /etc/tmpfiles.d/docker.conf
