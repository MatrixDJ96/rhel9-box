FROM docker.io/redhat/ubi9-init:latest

ENV container=docker

# Mask system services
RUN set -e; \
    systemctl mask \
        systemd-remount-fs.service \
        dev-hugepages.mount \
        sys-fs-fuse-connections.mount \
        systemd-logind.service getty.target \
        console-getty.service \
        systemd-udev-trigger.service \
        systemd-udevd.service \
        systemd-random-seed.service \
        systemd-machine-id-commit.service

# Run provisioning script
RUN --mount=type=bind,source=./config,target=/vagrant/config,ro \
    bash --login /vagrant/config/provision.sh

VOLUME [ "/var/lib/mysql" ]
VOLUME [ "/sys/fs/cgroup" ]

EXPOSE 80 443 2222 3306

CMD ["/usr/sbin/init"]
