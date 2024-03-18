# rhel9-box — a RHEL 9 web development environment

`config/provision.sh` runs the step scripts in `config/provision/` as root, inside the target.
Target: a Vagrant box (`Vagrantfile`).
The step scripts read the repository's `config/` at `/vagrant/config` in every target.

## Build & run

```bash
git ls-files -z '*.sh' | xargs -0 -n1 bash -n            # syntax-check every shell script
git ls-files -z '*.sh' | xargs -0 shellcheck -S error    # shellcheck, errors only
```

Run the check lines after every edit: the repository has no test suite.

## Conventions

- A new provisioning step is a script in `config/provision/` that `config/provision.sh` calls.
- `MYSQL_VERSION` (default `8.4`) picks the series; `mysql.sh` exits 1 if the server differs.
- PHP versions live in `php_versions` (`php.sh`); `PHP_VERSION=php84` installs one alone.

## Gotchas

- `git add` refuses a new `*.conf` in `config/apache/` and any file named `*tmp*`.
  `.gitignore` ignores both; add a file the box ships with `git add -f`.

## Boundaries

- The step scripts install packages and edit system files: never run them on the host.
  The first `vagrant up`, or `vagrant provision`, runs them inside the box.
