#!/bin/bash

cd $(dirname $0)

echo Running RHEL9...
docker rm -f rhel9 >/dev/null 2>&1
docker run -d --name rhel9 \
  # --privileged \
  --hostname vagrant.local \
  --security-opt label=disable \
  # -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -v /etc/localtime:/etc/localtime:ro \
  -v ~/.rhel9/home:/root \
  -v ~/.rhel9/mysql:/var/lib/mysql \
  -v ~/.rhel9/projects:/vagrant/projects \
  -v $(pwd)/config:/vagrant/config \
  -p 80:80 \
  -p 443:443 \
  -p 2222:2222 \
  -p 3306:3306 \
  # --cgroupns=host \
  local/rhel9-init
