#!/bin/bash

cd "$(dirname "$0")"

# Container engine: override with ENGINE=docker|podman, otherwise prefer podman.
if [ -z "${ENGINE}" ]; then
  if command -v podman >/dev/null 2>&1; then
    ENGINE=podman
  else
    ENGINE=docker
  fi
fi

echo "Running RHEL9 with ${ENGINE}..."

# The image runs systemd as PID 1. On cgroup v2 Docker needs explicit cgroup
# access and writable runtime dirs; podman provides them natively.
SYSTEMD_ARGS=()
if [ "${ENGINE}" = "docker" ]; then
  SYSTEMD_ARGS=(
    --cgroupns=host
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw
    --tmpfs /run
    --tmpfs /run/lock
    --tmpfs /tmp
  )
fi

"${ENGINE}" rm -f rhel9 >/dev/null 2>&1
"${ENGINE}" run -d --name rhel9 \
  --hostname vagrant.local \
  --security-opt label=disable \
  "${SYSTEMD_ARGS[@]}" \
  -v /etc/localtime:/etc/localtime:ro \
  -v ~/.rhel9/home:/root \
  -v ~/.rhel9/mysql:/var/lib/mysql \
  -v ~/.rhel9/projects:/vagrant/projects \
  -v "$(pwd)/config:/vagrant/config" \
  -p 80:80 \
  -p 443:443 \
  -p 2222:2222 \
  -p 3306:3306 \
  local/rhel9-init
