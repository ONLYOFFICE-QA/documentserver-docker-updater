# Change Log

## master (unreleased)

### New Features

* Add `connect` and `update` scripts for `kim.teamlab.info`
* Add `markdownlint` check via GitHub Actions
* Enable `WOPI` by default
* Add `yamllint` check in CI

### Changes

* Change container name to more generic `DocumentServer`
* Change repo name from `doc-linux-docker-updater` to
  `documentserver-docker-updater`
* Fix all `markdownlint` issues in `*.md` files
* Create symbolic links for executables, instead of copying
* Change installation and usage instruction
  considering `kim.teamlab.info`

### Fixes

* Fix old version of `nodejs` in CI
