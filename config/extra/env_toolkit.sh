#!/bin/bash

set -eo pipefail

if [[ "${1}" = "--root" ]] && [ "$(id -u)" != "0" ]; then
	echo "Restarting with sudo..."
	shift # Remove --root argument
	exec sudo "$0" "$@"
fi

source "$(dirname "$0")/engine.sh"

REGISTRY_URL="docker.io"
REPOSITORY_PATH="matrixdj96"

if [ "${1}" = "--docker-install" ]; then
	# Install Podman and Docker
	bash --login "$(pwd)/config/provision/docker.sh" --ubuntu
elif [ "${1}" = "--docker-build" ]; then
	# Build base image
	"${ENGINE}" image rm -f local/rhel9-init >/dev/null 2>&1
	"${ENGINE}" build --security-opt label=disable --load \
		-t local/rhel9-init \
		. 2>&1 | tee build.log
elif [ "${1}" = "--docker-export" ]; then
	# Create tmp container
	"${ENGINE}" rm -f rhel9 >/dev/null 2>&1
	"${ENGINE}" run -t -d -v "$(pwd):/vagrant" --name rhel9 local/rhel9-init bash

	# Configure container for WSL
	if [ "${2}" = "--wsl" ]; then
		"${ENGINE}" exec -t rhel9 /vagrant/config/extra/env_toolkit.sh --wsl-export
	fi

	# Export image
	"${ENGINE}" export rhel9 >RHEL9.wsl
	"${ENGINE}" rm -f rhel9 >/dev/null 2>&1
elif [ "${1}" = "--docker-pull" ]; then
  # Pull RHEL9 image
  "${ENGINE}" pull "${REGISTRY_URL}/${REPOSITORY_PATH}/rhel9-init:latest"
  "${ENGINE}" tag "${REGISTRY_URL}/${REPOSITORY_PATH}/rhel9-init:latest" local/rhel9-init
elif [ "${1}" = "--docker-push" ]; then
  # Push RHEL9 image
  "${ENGINE}" login "${REGISTRY_URL}"
  "${ENGINE}" tag local/rhel9-init "${REGISTRY_URL}/${REPOSITORY_PATH}/rhel9-init:latest"
  "${ENGINE}" push "${REGISTRY_URL}/${REPOSITORY_PATH}/rhel9-init:latest"
elif [ "${1}" = "--wsl-export" ]; then
	# Unmask system services
	systemctl unmask \
		systemd-remount-fs.service \
		dev-hugepages.mount \
		sys-fs-fuse-connections.mount \
		systemd-logind.service \
		getty.target \
		console-getty.service \
		systemd-udev-trigger.service \
		systemd-udevd.service \
		systemd-random-seed.service \
		systemd-machine-id-commit.service

	# Configure IPv6 and unprivileged ports
	mkdir -p /etc/sysctl.d
	echo "net.ipv6.conf.all.disable_ipv6=1" >/etc/sysctl.d/99-disable-ipv6.conf
	echo "net.ipv6.conf.default.disable_ipv6=1" >>/etc/sysctl.d/99-disable-ipv6.conf
	echo "net.ipv4.ip_unprivileged_port_start=0" >/etc/sysctl.d/99-unprivileged-ports.conf

	# Create default user
	if ! id "vagrant" >/dev/null 2>&1; then
		useradd "vagrant" && { echo "vagrant" | passwd --stdin "vagrant"; }
	fi
	sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
	echo "vagrant ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/vagrant
	chmod 0440 /etc/sudoers.d/vagrant

	# Configure wsl.conf
	echo -e "[boot]" >/etc/wsl.conf
	echo -e "systemd=true\n" >>/etc/wsl.conf
	echo -e "[network]" >>/etc/wsl.conf
	echo -e "generateHosts=false" >>/etc/wsl.conf
	echo -e "hostname=vagrant.local\n" >>/etc/wsl.conf
	echo -e "[user]" >>/etc/wsl.conf
	echo -e "default=vagrant" >>/etc/wsl.conf

	# Configure environment variables
	sed -i '/^container=/d' /etc/environment
	echo 'container=docker' >>/etc/environment

	# Disable MySQL and Keycloak
	systemctl disable mysqld
	systemctl disable keycloak
elif [ "${1}" = "--wsl-configure" ]; then
	# Enable linger for vagrant
	loginctl enable-linger vagrant

	# Link config files
	rm -fr /vagrant/config
	rm -fr /vagrant/documents
	mkdir -p /vagrant/projects
	ln -fs "$(pwd)/config" /vagrant/config
	ln -fs "$(pwd)/documents" /vagrant/documents
	chown -R vagrant:vagrant /vagrant
elif [ "${1}" = "--wsl-provision" ]; then
	APP_USER="vagrant"

	# Update PHP-FPM config
	sed -ri \
		-e "s/^\s*user\s*=.*/user = ${APP_USER}/" \
		-e "s/^\s*group\s*=.*/group = ${APP_USER}/" \
		/etc/opt/remi/*/php-fpm.d/www.conf

	# Update MySQL config
	sed -ri \
		-e "s/--user=[^ ]*/--user=${APP_USER}/" \
		/etc/sysconfig/mysql

	# Fix ownership for PHP
	for php_session_dir in /var/opt/remi/*/lib/php/session; do
		chown -R "${APP_USER}:${APP_USER}" "${php_session_dir}"
	done

	# Set Podman socket
	sed -i '/^\s*export DOCKER_HOST=.*$/d' /home/vagrant/.bashrc
	echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock' >>/home/vagrant/.bashrc

	# Enable MySQL and Keycloak
	systemctl daemon-reload
	systemctl enable --now mysqld
	systemctl enable --now keycloak

	echo "Waiting for Keycloak to start..."
	until systemctl is-failed --quiet keycloak || { systemctl status keycloak | grep -q "started in"; }; do
		sleep 5
	done
fi
