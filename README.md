# system-update
A system update script for developers, using Ubuntu / Debian / elementaryOS based systems or OpenSUSE based systems.

## Usage
```
# Daily - system packages from apt / zypper / snap / flatpak
./system-update.sh

# Weekly - updates for pipx / pyenv / uv / nvm / asdf / composer / cargo / devbox / docker
./system-update.sh --full
```
## Features

- Only runs updates for tools that are currently installed.
- Prunes unused Docker containers
- Optionally prunes leftover tooling caches

Support for other tools / operating systems are welcome.
