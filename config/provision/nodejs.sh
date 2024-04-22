#!/bin/bash

if [ -n "${NODE_VERSION:-}" ]; then
  node_versions=("${NODE_VERSION}")
else
  node_versions=(22 20 18)
fi

if [ "${1:-}" = "--uninstall" ]; then
  UNINSTALL=1
  shift
fi

NODE_USER="${1:-root}"
NODE_USER_HOME="$(eval echo "~${NODE_USER}")"

if [ -n "${UNINSTALL:-}" ]; then
  for version in "${node_versions[@]}"; do
    systemctl disable --now "pm2-${version}-${NODE_USER}" || true
    rm -f "/etc/systemd/system/pm2-${version}-${NODE_USER}.service"
  done

  rm -rf "${NODE_USER_HOME}/.pm2" /opt/mise/*
  exit 0
fi

cd "${HOME}" || exit

rm -rf ~/.local/share/mise/shims

mkdir -p ~/.local/share/mise/shims
mkdir -p ~/.local/share/mise/installs/node
mkdir -p ~/.local/share/mise/downloads/node

for version in "${node_versions[@]}"; do
  mise install "node@${version}"

  mise x "node@${version}" -- npm install yarn -g
  mise x "node@${version}" -- npm install pm2 -g

  PM2_HOME="${NODE_USER_HOME}/.pm2/${version}" mise x "node@${version}" --command "pm2 startup -u ${NODE_USER} --service-name pm2-${version}-${NODE_USER} && pm2 save -f"
done

mise reshim

chown -R "${NODE_USER}:" /opt/mise "${NODE_USER_HOME}/.pm2"

systemctl daemon-reload

for version in "${node_versions[@]}"; do
  systemctl enable "pm2-${version}-${NODE_USER}"
done
