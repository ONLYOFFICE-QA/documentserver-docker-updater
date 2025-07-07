# Change Log

## master (unreleased)

### New Features

* Add `pluginmaster.sh` containing methods for plug-in managing
* Add `get_plugins_script.py` for update `plugins-list-actual.json`
* Add `connect` and `update` scripts for `kim.teamlab.info`
* Add `markdownlint` check via GitHub Actions
* Enable `WOPI` by default
* Add `yamllint` check in CI
* Add `shellcheck` check in CI

### Changes

* Remove installing plugins after update
* Change container name to more generic `DocumentServer`
* Change repo name from `doc-linux-docker-updater` to
  `documentserver-docker-updater`
* Fix all `markdownlint` issues in `*.md` files
* Create symbolic links for executables, instead of copying
* Change installation and usage instruction
  considering `kim.teamlab.info`

### Fixes

* Fix old version of `nodejs` in CI
