# rhel9-box

A reproducible **RHEL 9** web development environment, provisioned with Vagrant.

The box boots a RHEL 9 guest and provisions a full web stack via shell scripts
under `config/provision/`, so every developer gets an identical environment
regardless of host OS.

## Stack

| Component        | Role                          |
| ---------------- | ----------------------------- |
| Apache (httpd)   | HTTP/HTTPS, name-based vhosts |
| MySQL            | Relational database           |
| PHP + Composer   | Application runtime, Xdebug   |
| Node.js (mise)   | Frontend tooling              |
| Java + Tomcat    | JVM application server        |
| Keycloak         | Identity / SSO                |
| Mercure          | SSE / real-time hub           |

## Requirements

- Vagrant
- One provider: VirtualBox, libvirt or VMware

## Quick start

```bash
cp settings.yaml.example settings.yaml   # set synced_folder.map to your projects path
vagrant up
```

The guest is reachable as `vagrant.local`. Exposed ports: 80 (HTTP), 443
(HTTPS), 2222 (SSH), 3306 (MySQL).

## Virtual hosts

Apache vhosts live in `config/apache/*.conf` and serve from `/vagrant/projects`.
Run `install_virtualhosts.sh` to map each `ServerName` into the host `hosts`
file (requires privileges to edit `/etc/hosts`).

## Project sources

Mount your code into the guest at `/vagrant/projects` via `synced_folder.map` in
`settings.yaml`.

## License

Apache-2.0 — see `LICENSE` and `NOTICE`.
