# rhel9-box — a RHEL 9 web development environment

`config/provision.sh` runs the step scripts in `config/provision/` as root, inside the target.
Targets: Vagrant box (`Vagrantfile`), systemd image (`Dockerfile`), WSL2 distro (`*.bat`).
The step scripts read the repository's `config/` at `/vagrant/config` in every target.

## Build & run

```bash
git ls-files -z '*.sh' | xargs -0 -n1 bash -n            # syntax-check every shell script
git ls-files -z '*.sh' | xargs -0 shellcheck -S error    # shellcheck, errors only
# lint the CI workflow
podman run --rm -v "$PWD":/repo:ro,z -w /repo docker.io/rhysd/actionlint:latest
./build.sh                                               # build local/rhel9-init from source
./run.sh                                                 # start the rhel9 container
```

Run the check lines after every edit: the repository has no test suite.

## Conventions

- A new provisioning step is a script in `config/provision/` that `config/provision.sh` calls.
- `MYSQL_VERSION` (default `8.4`) picks the series; `mysql.sh` exits 1 if the server differs.
- PHP versions live in `php_versions` (`php.sh`); `PHP_VERSION=php84` installs one alone.
- Node.js versions live in `node_versions` (`nodejs.sh`); `NODE_VERSION` installs one alone.
- The `*_version` variables atop `tomcat.sh`, `keycloak.sh` and `mercure.sh` pin each service.
- `config/provision/docker.sh` runs only from `prepare.bat`, on the Ubuntu WSL distro.

## Gotchas

- `git add` refuses a new `*.conf` in `config/apache/` and any file named `*tmp*`.
  `.gitignore` ignores both; add a file the box ships with `git add -f`.
- `./build.sh` asks `Do you want to skip build? [y/N]` and builds on any answer but `y` or `Y`.
  A closed input builds too; a non-empty `SKIP_BUILD` skips the build without asking.

## Boundaries

- The step scripts install packages and edit system files: never run them on the host.
  The first `vagrant up`, or `vagrant provision`, runs them inside the box.
- `run.sh`, `init.sh` and `export.sh` remove any existing container named `rhel9`.
  Check `podman ps -a` first; `ENGINE=echo ./run.sh` prints the `run` command instead.
- `push.sh` publishes `local/rhel9-init` as `docker.io/matrixdj96/rhel9-init:latest`.
  Ask the owner before running it; `./build.sh` alone builds without publishing.
- `import.bat` and `init.bat` unregister the WSL distro `RHEL9`, deleting its filesystem.
  Its `/vagrant/projects` goes with it: ask the owner before running either on a set-up host.
- A push to `master` touching a path outside the workflow's `paths-ignore` publishes `latest`.
  Ask the owner before pushing; commits stay local until then.
