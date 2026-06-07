# rhel9-box

[![Docker Hub](https://img.shields.io/docker/v/matrixdj96/rhel9-init?label=docker%20hub&sort=date)](https://hub.docker.com/r/matrixdj96/rhel9-init)

A reproducible **RHEL 9 (UBI 9)** web development environment, shipped as a
single systemd-enabled image. One container behaves like a full machine: every
service runs inside it, provisioned from a fixed set of shell scripts so the
environment is identical across hosts.

Contents: Prerequisites · Quick start · Architecture · Stack · Develop from source · Repository
layout · Virtual hosts · Build and publish · Troubleshooting · Third-party components · License

## Prerequisites

Pick the target you want; each has its own requirements.

- **Container (Linux / macOS)** — **Podman** (preferred) or **Docker** on a
  cgroup v2 host. Podman runs the systemd image natively; Docker needs a few
  extra flags (see `DOCKERHUB.md`).
- **WSL2 distro (Windows)** — Windows with **WSL2** enabled. First-time setup
  installs an Ubuntu WSL distro and a container engine via `prepare.bat`.
- **Vagrant box** — **Vagrant** plus a provider: VirtualBox, libvirt, or
  VMware.

## Quick start

[DOCKERHUB.md](DOCKERHUB.md) covers the published image on its own: the Podman and Docker
`run` commands, ports, persistence mounts and the `degraded` state on Docker.

From a clone of this repository, the convenience flow on Linux / macOS:

```bash
./init.sh   # pull the published image, start the container, set up hosts + SSH
```

See [Develop from source](#develop-from-source) for the full workflows and
their caveats.

## Architecture

The image is built from `redhat/ubi9-init` and runs `/usr/sbin/init` (systemd)
as PID 1, with non-essential units masked for container use. `config/provision.sh`
orchestrates the per-service scripts under `config/provision/`. The same
provisioning produces three delivery targets:

| Target        | Artifact                          | Registry / output         |
| ------------- | --------------------------------- | ------------------------- |
| Docker image  | systemd monolith                  | `docker.io/matrixdj96/rhel9-init` |
| WSL2 distro   | exported root filesystem tarball  | `RHEL9.wsl`               |
| Vagrant box   | VirtualBox / libvirt / VMware     | local provider            |

## Stack

| Component        | Role                          | Provisioned by                              |
| ---------------- | ----------------------------- | ------------------------------------------- |
| Apache (httpd)   | HTTP/HTTPS, name-based vhosts | `provision/apache.sh`                       |
| MySQL            | Relational database           | `provision/mysql.sh`                        |
| PHP + Composer   | Application runtime, Xdebug   | `provision/php.sh`, `provision/composer.sh` |
| Node.js (mise)   | Frontend tooling              | `provision/mise.sh`, `provision/nodejs.sh`  |
| Java + Tomcat    | JVM application server        | `provision/java.sh`, `provision/tomcat.sh`  |
| Keycloak         | Identity / SSO (BCrypt SPI)   | `provision/keycloak.sh`                     |
| Mercure          | SSE / real-time hub           | `provision/mercure.sh`                      |

## Develop from source

Clone this repository, then use one of the workflows below. The local container
runtime is driven by `run.sh`, which **auto-detects the engine** (prefers
Podman; set `ENGINE=docker` to force Docker) and applies the right systemd flags
for each. `run.sh` runs the image tagged `local/rhel9-init`, which must already
exist locally — `pull.sh`/`init.sh` produce it by pulling and tagging the
published image, and `build.sh` produces it by building from source.

> The engine auto-detection applies to `run.sh` only. The helper steps run by
> `init.sh` — `install_virtualhosts.sh` and `install_ssh_key.sh` — call
> `docker exec rhel9` directly and do **not** honor `ENGINE`, so the full
> `init.sh` convenience flow assumes the `docker` CLI is available. On a
> Podman-only host the container starts, but the hosts/SSH steps fail unless a
> `docker` shim points at Podman (see [Troubleshooting](#troubleshooting)).

### Local container — Linux / macOS

```bash
./init.sh                 # pull the published image, start the container, set up hosts + SSH
ENGINE=docker ./init.sh   # force Docker instead of Podman
```

### Windows — WSL2

First-time setup on a clean host:

```bat
prepare.bat
```

`prepare.bat` installs the Ubuntu WSL distro and the container engine. Then:

```bat
init.bat
```

`init.bat` pulls the prebuilt image, exports it as `RHEL9.wsl`, and imports it
as the WSL distro `RHEL9`. Enter it with `wsl -d RHEL9`.

### Vagrant

```bash
cp settings.yaml.example settings.yaml   # then set synced_folder.map (required)
vagrant up
```

Setting `synced_folder.map` is mandatory — `vagrant up` aborts without it. The
`Vagrantfile` first looks for a platform-specific settings file
(`settings.linux.yaml`, `settings.darwin.yaml`, or `settings.windows.yaml`) and
falls back to `settings.yaml`, so you may use a platform-specific name instead.

## Repository layout

```
.
├── run.sh                       # start the container (engine-aware)
├── init.sh / init.bat           # full local / WSL2 convenience flow
├── pull.sh / pull.bat           # pull + tag the published image as local/rhel9-init
├── build.sh / build.bat         # build the image from source
├── push.sh / push.bat           # build then push to the registry
├── export.sh / export.bat       # export the image (e.g. WSL tarball)
├── import.bat                   # import the WSL distro
├── install_virtualhosts.{sh,bat}# map vhost ServerNames into the host hosts file
├── install_ssh_key.{sh,bat}     # generate + install the SSH key
├── prepare.bat                  # Windows first-time setup (Ubuntu WSL + engine)
├── Dockerfile                   # FROM redhat/ubi9-init, systemd PID 1
├── Vagrantfile
├── settings.yaml.example
└── config/
    ├── provision.sh             # orchestrates the per-service provisioning steps
    ├── provision/               # per-service scripts (apache, mysql, php, …)
    ├── extra/env_toolkit.sh     # build / export / pull / push / WSL toolkit
    ├── apache/                  # name-based virtual host configs
    └── <service>/               # systemd units, environment, overrides per service
```

## Virtual hosts

Apache includes `/vagrant/config/apache/*.conf` at runtime (`config/provision/apache.sh`),
so a vhost loads only where `/vagrant/config` is this repository's `config/`. `run.sh`, the
`Vagrantfile` and the WSL2 setup provide it; the `Dockerfile` mounts it at build time only, so
the published image needs `-v <path>/config:/vagrant/config` with `<path>` a clone of this
repository (the `run` commands in `DOCKERHUB.md` carry it).

The tracked confs are the box's own: `000-default.conf` serves `/var/www`, the `001-*.conf`
confs proxy Keycloak, Mercure and Tomcat (`keycloak.local`, `mercure.local`, `tomcat.local`),
and `999-custom.conf` holds the proxy settings. A project's vhost is added by the box's user as
a conf in `config/apache/` pointing into `/vagrant/projects`; git ignores it
(`/config/apache/*.conf` in `.gitignore`). The `install_virtualhosts.{sh,bat}` scripts map
each `ServerName` into the host `hosts` file.

## Build and publish

```bash
./build.sh   # build the monolith image locally (interactive)
./push.sh    # build, then push to docker.io/matrixdj96/rhel9-init
```

`build.sh` prompts `Do you want to skip build? [y/N]` unless `SKIP_BUILD` is set
in the environment, so set `SKIP_BUILD=1` to run it non-interactively. `push.sh`
runs `build.sh` first and then pushes, so it rebuilds before publishing.

`config/extra/env_toolkit.sh` is the underlying build/export/pull/push
orchestrator (Docker and WSL flows). The published image is also built by CI
(see `.github/workflows/docker.yml`):

- on pushes to `master` that touch image inputs (doc- and script-only changes
  are excluded via `paths-ignore`),
- on a weekly schedule (Monday 04:00 UTC),
- on manual `workflow_dispatch`.

Builds are tagged `latest` and `YYYYMMDD-<short-sha>`.

## Troubleshooting

- **Docker on a cgroup v2 host** — the image runs systemd as PID 1, so Docker
  needs the extra flags the Docker command in `DOCKERHUB.md` carries
  (Podman provides these natively). `run.sh` applies them automatically when the
  engine is Docker.

- **`./init.sh` fails after starting the container on a Podman-only host** —
  the hosts/SSH helpers (`install_virtualhosts.sh`, `install_ssh_key.sh`) call
  `docker exec rhel9` directly. Provide a `docker` command that points at Podman
  (e.g. a shim or alias), or run those steps manually, then re-run `init.sh`.

## Third-party components

`config/keycloak/keycloak-bcrypt-1.6.0.jar` — BCrypt password provider for
Keycloak ([leroyguillaume/keycloak-bcrypt](https://github.com/leroyguillaume/keycloak-bcrypt),
Apache-2.0), bundling `at.favre.lib:bcrypt` and `at.favre.lib:bytes`. See
`NOTICE`.

## License

Apache-2.0 — see `LICENSE` and `NOTICE`.
