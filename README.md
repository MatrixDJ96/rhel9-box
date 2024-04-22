# rhel9-box

A reproducible **RHEL 9** web development environment, shipped as a Vagrant box. Every
service runs inside the box, provisioned from a fixed set of shell scripts so the
environment is identical across hosts.

Contents: Prerequisites · Stack · Develop from source · Repository layout · Virtual hosts ·
License

## Prerequisites

- **Vagrant box** — **Vagrant** plus a provider: VirtualBox, libvirt, or
  VMware.

## Stack

| Component        | Role                          | Provisioned by                              |
| ---------------- | ----------------------------- | ------------------------------------------- |
| Apache (httpd)   | HTTP/HTTPS, name-based vhosts | `provision/apache.sh`                       |
| MySQL            | Relational database           | `provision/mysql.sh`                        |
| PHP + Composer   | Application runtime, Xdebug   | `provision/php.sh`, `provision/composer.sh` |
| Node.js (mise)   | Frontend tooling              | `provision/mise.sh`, `provision/nodejs.sh`  |

## Develop from source

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

```text
.
├── Vagrantfile
├── settings.yaml.example
├── LICENSE / NOTICE              # Apache License 2.0 and its notice
└── config/
    ├── provision.sh              # orchestrates the per-service provisioning steps
    ├── provision/                # per-service scripts (apache, mysql, php, …)
    ├── apache/                   # name-based virtual host configs
    └── <service>/                # environment and overrides per service
```

## Virtual hosts

Apache includes `/vagrant/config/apache/*.conf` at runtime (`config/provision/apache.sh`),
so a vhost loads only where `/vagrant/config` is this repository's `config/`, as the
`Vagrantfile` provides it.

## License

Apache-2.0 — see `LICENSE` and `NOTICE`.
