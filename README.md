# rhel9-box

A reproducible **RHEL 9** web development environment, shipped as a Vagrant box. Every
service runs inside the box, provisioned from a fixed set of shell scripts so the
environment is identical across hosts.

Contents: Prerequisites · Stack · Develop from source · Repository layout · Virtual hosts ·
Third-party components · License

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
| Java + Tomcat    | JVM application server        | `provision/java.sh`, `provision/tomcat.sh`  |
| Keycloak         | Identity / SSO (BCrypt SPI)   | `provision/keycloak.sh`                     |
| Mercure          | SSE / real-time hub           | `provision/mercure.sh`                      |

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
├── LICENSE / NOTICE              # Apache License 2.0, bundled keycloak-bcrypt notice
└── config/
    ├── provision.sh              # orchestrates the per-service provisioning steps
    ├── provision/                # per-service scripts (apache, mysql, php, …)
    ├── apache/                   # name-based virtual host configs
    └── <service>/                # systemd units, environment, overrides per service
```

## Virtual hosts

Apache includes `/vagrant/config/apache/*.conf` at runtime (`config/provision/apache.sh`),
so a vhost loads only where `/vagrant/config` is this repository's `config/`, as the
`Vagrantfile` provides it.

The tracked confs are the box's own: `000-default.conf` serves `/var/www`, the `001-*.conf`
confs proxy Keycloak, Mercure and Tomcat (`keycloak.local`, `mercure.local`, `tomcat.local`),
and `999-custom.conf` holds the proxy settings. A project's vhost is added by the box's user as
a conf in `config/apache/` pointing into `/vagrant/projects`; git ignores it
(`/config/apache/*.conf` in `.gitignore`).

## Third-party components

`config/keycloak/keycloak-bcrypt-1.6.0.jar` — BCrypt password provider for
Keycloak ([leroyguillaume/keycloak-bcrypt](https://github.com/leroyguillaume/keycloak-bcrypt),
Apache-2.0), bundling `at.favre.lib:bcrypt` and `at.favre.lib:bytes`. See
`NOTICE`.

## License

Apache-2.0 — see `LICENSE` and `NOTICE`.
