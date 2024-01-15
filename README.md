# rhel9-box

A reproducible **RHEL 9** web development environment, shipped as a Vagrant box. Every
service runs inside the box, provisioned from a fixed set of shell scripts so the
environment is identical across hosts.

Contents: Prerequisites · Develop from source · Repository layout · License

## Prerequisites

- **Vagrant box** — **Vagrant** plus a provider: VirtualBox, libvirt, or
  VMware.

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
    └── provision/                # per-service scripts
```

## License

Apache-2.0 — see `LICENSE` and `NOTICE`.
