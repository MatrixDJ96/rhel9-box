# rhel9-init

A reproducible **RHEL 9 (UBI 9)** web development environment, shipped as a
single **systemd-enabled** image. One container behaves like a full machine:
every service runs inside it, managed by systemd (`/usr/sbin/init`).

## What's inside

Apache (name-based vhosts), MySQL, PHP + Composer (Xdebug), Node.js (mise),
Java + Tomcat, Keycloak (BCrypt SPI), Mercure.

## Tags

- `latest` — most recent build from the default branch
- `YYYYMMDD-<commit>` — build date plus short commit, for exact traceability

## Quick run

The image runs systemd as PID 1, so it needs systemd-container settings.
**Podman** provides them natively:

```bash
podman run -d --name rhel9 \
  --hostname vagrant.local \
  --security-opt label=disable \
  -v ~/.rhel9/home:/root \
  -v ~/.rhel9/mysql:/var/lib/mysql \
  -v ~/.rhel9/projects:/vagrant/projects \
  -p 80:80 -p 443:443 -p 2222:2222 -p 3306:3306 \
  docker.io/matrixdj96/rhel9-init:latest
```

**Docker** (on a cgroup v2 host) needs cgroup access and writable runtime dirs:

```bash
docker run -d --name rhel9 \
  --hostname vagrant.local \
  --security-opt label=disable \
  --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --tmpfs /run --tmpfs /run/lock --tmpfs /tmp \
  -v ~/.rhel9/home:/root \
  -v ~/.rhel9/mysql:/var/lib/mysql \
  -v ~/.rhel9/projects:/vagrant/projects \
  -p 80:80 -p 443:443 -p 2222:2222 -p 3306:3306 \
  matrixdj96/rhel9-init:latest
```

Put your project sources in `~/.rhel9/projects` (mounted at
`/vagrant/projects`); Apache virtual hosts serve from there.

> On Docker, `systemctl is-system-running` reports `degraded` only because
> `upower.service` (power management) cannot start without extra privileges — it
> is irrelevant here and all web services run normally.

## Ports

| Port | Service |
| ---- | ------- |
| 80   | HTTP    |
| 443  | HTTPS   |
| 2222 | SSH     |
| 3306 | MySQL   |

## Persistence

Bind-mount these on the host to keep state across container recreation:

```
~/.rhel9/home      -> /root
~/.rhel9/mysql     -> /var/lib/mysql
~/.rhel9/projects  -> /vagrant/projects
```

## Full toolchain and sources

Helper scripts (`init.sh`, build/push, WSL2 export, Vagrant box) and all
configuration live in the GitHub repository:

**https://github.com/MatrixDJ96/rhel9-box**

## License

Apache-2.0. Bundles `keycloak-bcrypt` (Apache-2.0). See `LICENSE` and `NOTICE`
in the repository.
