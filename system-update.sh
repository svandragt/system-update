#!/usr/bin/env bash

# KB used on the filesystem holding $HOME.
disk_used_kb() {
  df -Pk "$HOME" | awk 'NR==2 {print $3}'
}

prune_docker() {
  if ! command -v docker &> /dev/null
  then
    return
  fi
  docker container prune -f
  docker image prune -f
  docker network prune -f
  docker builder prune -f
}

# clear_if_large <name> <dir> <threshold_gb> <clear command...>
# Runs the aggressive clear command only when the cache exceeds the threshold,
# so big caches get a full wipe occasionally instead of every week.
clear_if_large() {
  local name="$1" dir="$2" threshold_gb="$3"; shift 3
  [ -d "$dir" ] || return
  local kb threshold_kb
  kb=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
  threshold_kb=$(( threshold_gb * 1024 * 1024 ))
  if [ "${kb:-0}" -gt "$threshold_kb" ]; then
    echo
    echo ">>> $name cache is $(du -sh "$dir" 2>/dev/null | awk '{print $1}') (> ${threshold_gb}G), clearing..."
    "$@"
  fi
}

prune_caches() {
  # Define the list of command and cache directory pairs
  declare -A command_cache
  command_cache=(
    ["ag"]="$HOME/.cache/ag"
    ["cmake"]="$HOME/.cache/cmake"
    ["composer"]="$HOME/.composer"
    ["deno"]="$HOME/.cache/deno"
    ["devbox"]="$HOME/.cache/devbox"
    ["docker"]="$HOME/.docker"
    ["gem"]="$HOME/.gem"
    ["go"]="$HOME/.cache/go-build"
    ["gradle"]="$HOME/.gradle"
    ["maven"]="$HOME/.m2"
    ["nix"]="$HOME/.cache/nix"
    ["node"]="$HOME/.node-gyp"
    ["npm"]="$HOME/.npm"
    ["pip"]="$HOME/.cache/pip"
    ["poetry"]="$HOME/.cache/pypoetry"
    ["ruby"]="$HOME/.bundle"
    ["cargo"]="$HOME/.cargo"
    ["rustup"]="$HOME/.rustup"
    ["subl"]="$HOME/.cache/sublime-text"
    ["tig"]="$HOME/.cache/tig"
    ["uv"]="$HOME/.cache/uv"
    ["yarn"]="$HOME/.yarn"
    ["pnpm"]="$HOME/.cache/pnpm"
  )

  # Iterate over the command and cache directory pairs
  for command in "${!command_cache[@]}"; do
    cache_dir="${command_cache[$command]}"
    answer=""

    # Check if the command is installed
    if ! command -v "$command" &> /dev/null; then
      # If the command is not installed, delete the cache directory
      if [ -d "$cache_dir" ]; then
        size=$(du -sh "$cache_dir" | awk '{print $1}')
        read -p "Do you want to delete the orphaned cache for $command [$cache_dir (${size})]? (y/N): " answer
        if [ "$answer" == "y" ]; then
          echo "Deleting cache directory for $command: $cache_dir"
          rm -rf "$cache_dir"
        else
          echo "Skipped $command: $cache_dir"
        fi
      fi
    fi
  done
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
  sudo apt-get update -qq && sudo apt-get full-upgrade -y || return
  echo;
  echo ">>> Updating missing linux headers..."
  sudo apt-get install "linux-headers-$(uname -r)" -y
}

cleanup_apt() {
  if ! command -v apt-get &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Cleaning apt packages..."
  sudo apt-get autoremove -y
  sudo apt-get autoclean -y
  sudo apt-get clean
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

  if command -v cargo-install-update &> /dev/null
  then
    cargo install-update -a
  fi
}

cleanup_cargo() {
  if ! command -v cargo &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Cleaning cargo registry cache..."
  if command -v cargo-cache &> /dev/null
  then
    # Gentle: removes re-downloadable registry src/cache, keeps installed binaries.
    cargo cache --autoclean
  else
    # No cargo-cache: only wipe the re-downloadable registry caches (never ~/.cargo/bin),
    # and only once they have grown large.
    clear_if_large "cargo registry" "$HOME/.cargo/registry" 2 \
      rm -rf "$HOME/.cargo/registry/cache" "$HOME/.cargo/registry/src"
  fi
  # rustup is intentionally left alone: wiping ~/.rustup removes installed
  # toolchains entirely, and there is no safe "prune only stale toolchains" command.
}

update_claude() {
  if ! command -v claude &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating claude..."
  claude update
}

update_composer() {
  if ! command -v composer &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating composer global packages..."

  composer_path=$(command -v composer)
  if [ -w "$composer_path" ]
  then
    composer self-update
  else
    sudo composer self-update
  fi
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
  devbox global update
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
}

update_fwupd() {
  if ! command -v fwupdmgr &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Checking firmware updates..."
  # Refresh metadata (rate-limited to once/24h, so allow it to no-op) and list
  # what is available. Flashing is left to the user: `sudo fwupdmgr update`.
  sudo fwupdmgr refresh || true
  sudo fwupdmgr get-updates || true
}

update_vscode() {
  for editor in code codium; do
    if command -v "$editor" &> /dev/null
    then
      echo;
      echo ">>> Updating $editor extensions..."
      "$editor" --update-extensions
    fi
  done
}

cleanup_flatpak() {
  if ! command -v flatpak &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Removing unused flatpaks..."
  sudo flatpak uninstall --system --unused -y
  flatpak uninstall --user --unused -y
}

cleanup_logs() {
  if ! command -v journalctl &> /dev/null && ! command -v logrotate &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Cleaning system logs..."

  if command -v journalctl &> /dev/null
  then
    sudo journalctl --vacuum-size=500M
  fi

  if command -v logrotate &> /dev/null && [ -f /etc/logrotate.conf ]
  then
    sudo logrotate -f /etc/logrotate.conf
  fi
}

cleanup_snapper() {
  if ! command -v snapper &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Cleaning up old snapper snapshots..."
  sudo snapper cleanup number
}

update_npm() {
  if ! command -v npm &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating npm global packages..."
  npm update -g
}

cleanup_npm() {
  if ! command -v npm &> /dev/null
  then
    return
  fi
  [ -d "$HOME/.npm" ] || return
  # verify re-hashes the whole cache, so skip it on trivially small caches
  # where it would just be a slow no-op.
  local kb
  kb=$(du -sk "$HOME/.npm" 2>/dev/null | awk '{print $1}')
  if [ "${kb:-0}" -gt $(( 1 * 1024 * 1024 )) ]; then
    echo;
    echo ">>> Verifying npm cache..."
    # Gentle: garbage-collects unused/corrupt entries without a full wipe.
    npm cache verify
  fi
  # Aggressive full wipe only when the cache has grown large.
  clear_if_large "npm" "$HOME/.npm" 5 npm cache clean --force
}

cleanup_go() {
  if ! command -v go &> /dev/null
  then
    return
  fi
  # Go auto-trims its build cache, so only force a full wipe when it grows large.
  clear_if_large "go" "$HOME/.cache/go-build" 5 go clean -cache
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

update_tldr() {
  if ! command -v tldr &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating tldr..."
  tldr -u
}

update_uv() {
  if ! command -v uv &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Updating uv packages..."
  uv self update --no-progress
  uv tool upgrade --all
}

prune_uv() {
  if ! command -v uv &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Pruning uv cache..."
  uv cache prune
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

cleanup_zypper() {
  if ! command -v zypper &> /dev/null
  then
    return
  fi
  echo;
  echo ">>> Cleaning zypper caches..."
  sudo zypper clean --all
}


# sys
update_apt
update_zypper
update_snap
update_flatpak
update_fwupd

if [[ "$1" == "--full" || "$1" == "-f" ]]; then
  cleanup_apt
  update_tldr
  # web
  update_vscode
  update_npm
  update_pipx
  update_pyenv
  update_asdf
  # Prune the uv cache before devbox: devbox kicks off background uv/nix work
  # that holds the cache lock and would otherwise make prune_uv hang.
  # Measured on its own so its reclaim still counts toward the final summary,
  # without the intervening update downloads polluting the number.
  uv_before=$(disk_used_kb)
  prune_uv
  uv_freed_kb=$(( uv_before - $(disk_used_kb) ))
  [ "$uv_freed_kb" -lt 0 ] && uv_freed_kb=0
  update_devbox
  update_claude
  update_composer
  update_cargo
  update_uv

  # disk space
  used_before=$(disk_used_kb)
  cleanup_zypper
  cleanup_flatpak
  cleanup_logs
  cleanup_snapper
  cleanup_npm
  cleanup_go
  cleanup_cargo
  prune_docker
  prune_caches

  # Report space reclaimed by the cleanup section, plus the earlier uv prune.
  freed_kb=$(( used_before - $(disk_used_kb) + uv_freed_kb ))
  echo
  if [ "$freed_kb" -gt 0 ]; then
    echo ">>> Reclaimed $(echo "$freed_kb" | awk '{
      kb=$1;
      if (kb >= 1024*1024) printf "%.1fG", kb/1024/1024;
      else if (kb >= 1024) printf "%.0fM", kb/1024;
      else printf "%dK", kb;
    }') of disk space."
  else
    echo ">>> No disk space reclaimed."
  fi
fi

if [ -f "/var/run/reboot-required" ]; then
    echo 
    echo "A reboot is recommended."
fi

# Nice goodbye
if command -v fortune &> /dev/null
then
    echo
    fortune -s
fi
