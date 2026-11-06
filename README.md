# documentserver-docker-updater

Scripts for updating test ONLYOFFICE DocumentServer instances
(`doc-linux.teamlab.info`, `kim.teamlab.info`) running in Docker.

## Table of contents

- [How it works](#how-it-works)
- [Installation](#installation)
- [Usage](#usage)
- [What the update does](#what-the-update-does)
- [S3 integration](#s3-integration)
- [Plugins list](#plugins-list)
- [Updating fonts](#updating-fonts)
- [Repository structure](#repository-structure)
- [CI checks](#ci-checks)

## How it works

```text
local machine                        remote server (root)
─────────────                        ────────────────────
doc-linux-update  ── ssh -t ──▶  docker-update.sh
kim-update                          ├─ stop-service.sh   (stop old container)
                                    ├─ docker run        (new container)
                                    └─ after-run.sh      (configure + restart)
                                         └─ s3/s3_connector.py (optional)
```

The `*-update` and `*-connect` commands are thin wrappers around `ssh`.
All the real work is done on the server by `docker-update.sh`.

## Installation

### On the local machine

```shell
ssh-copy-id root@doc-linux.teamlab.info
ssh-copy-id root@kim.teamlab.info
git clone https://github.com/onlyoffice-testing-robot/documentserver-docker-updater.git
cd documentserver-docker-updater
mkdir -pv ~/bin
ln -s $PWD/doc-linux-connect $HOME/bin/doc-linux-connect
ln -s $PWD/doc-linux-update $HOME/bin/doc-linux-update
ln -s $PWD/kim-connect $HOME/bin/kim-connect
ln -s $PWD/kim-update $HOME/bin/kim-update
```

Open a new terminal window — the commands should be available
(`~/bin` must be in `PATH`).

### On each server

The update commands run `cd documentserver-docker-updater` in the home
directory of `root`, so this repository must be cloned there as well:

```shell
git clone https://github.com/onlyoffice-testing-robot/documentserver-docker-updater.git
```

Keep it up to date with `git pull` — the server runs the scripts from
its own copy, not from your local one.

## Usage

Both servers have the same set of commands. Replace the prefix
(`doc-linux` or `kim`) to choose the server.

- `doc-linux-connect` — open an ssh session to `doc-linux.teamlab.info`
- `doc-linux-update` — update to the `latest` docker tag
- `doc-linux-update 5.0.0.56` — update to a specific docker tag
- `doc-linux-update latest with-s3` — update to `latest`
  with S3 integration
- `doc-linux-update 5.0.0.56 with-s3` — update to a specific tag
  with S3 integration
- `kim-connect` — open an ssh session to `kim.teamlab.info`
- `kim-update [tag] [with-s3]` — same as `doc-linux-update`,
  for `kim.teamlab.info`

Arguments of `*-update`:

1. `tag` — docker tag of `onlyoffice/4testing-documentserver-ee`
   (default: `latest`).
2. `with-s3` — optional; configure S3 file storage after start
   (see [S3 integration](#s3-integration)).

## What the update does

`docker-update.sh` performs the following steps on the server:

1. Creates log and cache folders in
   `/var/log/onlyoffice/documentserver/<YYYY-MM-DD-HH-MM>/`.
2. Runs `stop-service.sh`: prepares DocumentServer for shutdown, stops the
   old container and **removes unused docker data**
   (`docker system prune -af`, `docker volume prune -f`).
3. Starts a new container named `DocumentServer`
   (ports `80` and `443`, `--restart=always`) with:
   - JWT enabled (`JWT_ENABLED=true`, header `AuthorizationJwt`);
   - `WOPI` enabled (`WOPI_ENABLED=true`);
   - mounted volumes: fonts (`/usr/share/fonts`), data
     (`/opt/onlyoffice/Data`), logs and file cache.
4. Runs `after-run.sh`, which waits for `ds:docservice` and `ds:converter`
   to become `RUNNING` (up to 60 attempts, 5 seconds each) and then:
   - edits `default.json`: `autoAssembly.enable=true`,
     `expire.files=3600`, `editor.maxChangesSize="20mb"`,
     `converter.errorfiles="error"` (file owner and mode are preserved);
   - sets the log level to `ALL`;
   - enables autostart of the `ds-example` service;
   - enables the nginx access log;
   - prints the installed package version;
   - applies the S3 configuration, if requested;
   - restarts all services (`supervisorctl restart all`).

> **Warning:** step 2 deletes all unused docker images, containers
> and volumes on the server, not only DocumentServer ones.

## S3 integration

With the `with-s3` argument, DocumentServer uses Amazon S3 for file
storage. The update then automatically:

- generates a config from [s3/s3_config/base_config.json](s3/s3_config/base_config.json)
  and the credentials;
- copies it to the container as
  `/etc/onlyoffice/documentserver/local-production-linux.json`;
- restarts the services (once, at the end of `after-run.sh`).

### Credentials

Credentials are read **on the server** (the script runs there) from
the home directory of the user that runs the update (`root`):

| File               | Content                      |
|--------------------|------------------------------|
| `~/.s3/key`        | AWS Access Key ID            |
| `~/.s3/private_key`| AWS Secret Access Key        |

Both files must exist and must not be empty. Requires `python3`.

### Bucket settings

Bucket, region and endpoint are set in
[s3/s3_config/base_config.json](s3/s3_config/base_config.json).
Edit this file to use another bucket.

### Manual run

```shell
python3 s3/s3_connector.py --name DocumentServer [--no-restart]
```

| Option         | Description                                         |
|----------------|-----------------------------------------------------|
| `--name`       | Container name (default: `DocumentServer`)          |
| `--no-restart` | Do not restart services after copying the config    |

## Plugins list

`plugins/plugins-list-actual.json` is the list of plugins from the
[onlyoffice.github.io](https://github.com/ONLYOFFICE/onlyoffice.github.io)
store, without the ones listed in `plugins/excluded-plugins-list.json`.

To regenerate it:

> Requirements: `python3`, `requests`

```shell
python3 plugins/get_plugins_script.py
```

> Plugins are **not** installed automatically during an update.
> `pluginsmaster.sh` provides the `_install_plugins <container>` function
> for installing them manually.

## Updating fonts

1. Add font files to the repo
   [doc-linux-fonts](https://github.com/ONLYOFFICE-QA/doc-linux-fonts).
2. Connect to the server and update the repo:

   ```shell
   cd /usr/share/fonts/custom/doc-linux-fonts/
   git pull
   ```

3. Update DocumentServer (`doc-linux-update` / `kim-update`).

## Repository structure

- `doc-linux-connect`, `kim-connect` — ssh into the server
- `doc-linux-update`, `kim-update` — run `docker-update.sh` on the server
- `docker-update.sh` — main update script (runs on the server)
- `stop-service.sh` — stop and clean up the old container
- `after-run.sh` — post-start configuration of the container
- `pluginsmaster.sh` — helper for installing plugins
- `plugins/` — plugins lists and the script to refresh them
- `s3/` — S3 configuration: `s3_connector.py`, `s3_config/`, `docker/`
- `.github/workflows/check.yml` — CI checks
- `CHANGELOG.md` — change history

## CI checks

On every push GitHub Actions runs: `yamllint`, `markdownlint` (`*.md`),
`shellcheck` and `flake8`. To check locally:

```shell
markdownlint *.md
shellcheck *.sh doc-linux-* kim-*
flake8
```
