# system-update
A system update script for developers, using Ubuntu / Debian / elementaryOS based systems or OpenSUSE based systems.

## Usage
```
# Daily Example - system packages from apt / zypper / snap / flatpak
./system-update.sh

# Weekly example, update everything
./system-update.sh --full
```
## Features

- Only runs updates for tools that are currently installed.
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
 - nvm
 - pipx
 - pyenv
 - snap
 - uv
 - zypper
