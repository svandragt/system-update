#!/usr/bin/env bash

prune_docker() {
  if ! command -v docker &> /dev/null
  then
    return
  fi
  docker container prune
  docker image prune
  docker network prune
}

update_asdf() {
  if ! command -v asdf &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating asdf"
  asdf update
  asdf plugin update --all
}

update_apt() {
  if ! command -v apt-get &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating apt-get packages..."
  sudo apt-get update -qq
  sudo apt-get full-upgrade -y
  echo ">>> Updating missing linux headers..."
  sudo apt-get install linux-headers-$(uname -r) -y
}

update_cargo() {
  if ! command -v cargo &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating rust and cargo global packages..."
  
  if command -v rustup &> /dev/null
  then
    rustup update
  fi
  cargo install-update --all
}

update_composer() {
  if ! command -v composer &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating composer global packages..."
  
  sudo composer self-update
  composer global update
}

update_devbox() {
  if ! command -v devbox &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating devbox..."
  
  devbox version update
}

update_flatpak() {
  if ! command -v flatpak &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating flatpaks..."
  sudo flatpak update -y
  flatpak update --user -y
  echo ">>> Removing unused flatpaks..."
  flatpak uninstall --unused -y
}

update_nvm() {
  if ! command -v nvm &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating nvm lts..."
  update-nvm.sh
  nvm install "lts/*" --reinstall-packages-from="$(nvm current)"
  nvm install "lts/gallium"
  nvm list
}

update_pipx() {
  if ! command -v pipx &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating pipx packages..." 
  pipx upgrade-all
}

update_pyenv() {
  if ! command -v pyenv &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating pyenv packages..."
  pyenv update
}
update_snap() {
  if ! command -v snap &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating snaps..."
  sudo snap refresh
}

update_uv() {
  if ! command -v uv &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating uv packages..."
  uv self update --no-progress
}

update_zypper() {
  if ! command -v zypper &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating zypper packages..."
  sudo zypper dup
  sudo zypper ps -s
}

# sys
update_apt
update_zypper
update_snap
update_flatpak

if [[ "$1" == "--full" || "$1" == "-f" ]]; then
  sudo apt-get autoremove -y  
  # web
  update_pipx
  update_pyenv
  update_nvm
  update_asdf
  update_composer
  update_cargo
  update_devbox
  update_uv

  # disk space
  prune_docker
fi


if [ -f "/var/run/reboot-required" ]; then
    echo 
    echo "Reboot is required."

      # Prompt for confirmation
    read -p "Do you want to reboot now? (y/N): " answer
    
    # Check the user's response
    if [ "$answer" == "y" ]; then
        shutdown -r now
    else
        echo "Reboot cancelled."
    fi
fi
