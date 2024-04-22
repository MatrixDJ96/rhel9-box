#!/bin/bash

cd "${HOME}" || exit

rm -rf ~/.local/share/mise/shims

mkdir -p ~/.local/share/mise/shims
mkdir -p ~/.local/share/mise/installs/node
mkdir -p ~/.local/share/mise/downloads/node

mise install node@20
mise install node@18

mise x node@20 -- npm install yarn -g
mise x node@18 -- npm install yarn -g

mise x node@20 -- npm install pm2 -g
mise x node@18 -- npm install pm2 -g

mise reshim

PM2_HOME=/root/.pm2/20 mise x node@20 --command "pm2 startup && pm2 save -f"
mv /etc/systemd/system/pm2-root.service /etc/systemd/system/pm2-20-root.service

PM2_HOME=/root/.pm2/18 mise x node@18 --command "pm2 startup && pm2 save -f"
mv /etc/systemd/system/pm2-root.service /etc/systemd/system/pm2-18-root.service

systemctl daemon-reload
systemctl enable pm2-20-root pm2-18-root
