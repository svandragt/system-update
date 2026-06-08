# system-update
A system update script for developers, using Ubuntu / Debian / elementaryOS based systems or OpenSUSE based systems.

## Usage
```
# Daily Example - update system packages from apt / zypper / snap / flatpak
./system-update.sh

# Weekly example - broader maintenance and safe disk cleanup
./system-update.sh --full
```
## Features

- Only runs updates for tools that are currently installed.
- Adds conservative APT cleanup on `--full` with `autoremove`, `autoclean`, and `clean`
- Cleans zypper package caches on `--full`
- Vacuums systemd journals and forces log rotation on `--full` when supported
- Removes unused Flatpak runtimes on `--full`
- Applies snapper retention policy to old snapshots on `--full`
- Prunes unused Docker containers, dangling images, and build cache
- Prunes the uv wheel/source cache on `--full`
- Verifies (garbage-collects) the npm cache on `--full` when it is large, with a full wipe only past 5G
- Wipes the Go build cache on `--full` only when it grows past 5G
- Cleans the cargo registry cache on `--full` (via `cargo-cache` if present, otherwise wipes re-downloadable registry caches past 2G; leaves rustup toolchains untouched)
- Reports the disk space reclaimed at the end of a `--full` run
- Checks for firmware updates with `fwupd` (refreshes metadata and lists available updates; flashing is left to you via `sudo fwupdmgr update`)
- Updates VSCode / VSCodium extensions on `--full` (`code`/`codium --update-extensions`)

> **Note on `fwupd`:** on some systems (e.g. Ubuntu 22.04) the snap build of `fwupd` is more up to date than the apt one. If you want the fresher version: `sudo apt remove --purge fwupd && sudo snap install fwupd`.
- Optionally prunes leftover tooling caches

Support for other tools / operating systems are welcome.

## Tools

The following tools are supported (this list is periodically updated):

 - apt
 - asdf
 - caches
 - cargo
 - claude
 - composer
 - devbox
 - docker
 - flatpak
 - fwupd
 - go
 - npm
 - pipx
 - pyenv
 - snap
 - snapper
 - tldr
 - uv
 - vscode / vscodium
 - zypper
