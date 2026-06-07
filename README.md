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
 - npm
 - pipx
 - pyenv
 - snap
 - snapper
 - tldr
 - uv
 - zypper
