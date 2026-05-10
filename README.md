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
- Vacuums systemd journals and forces log rotation on `--full` when supported
- Removes unused Flatpak runtimes on `--full`
- Prunes unused Docker containers
- Optionally prunes leftover tooling caches

Support for other tools / operating systems are welcome.

## Tools

The following tools are supported (this list is periodically updated):

 - apt
 - asdf
 - caches
 - cargo
 - composer
 - devbox
 - docker
 - flatpak
 - pipx
 - pyenv
 - snap
 - tldr
 - uv
 - zypper
