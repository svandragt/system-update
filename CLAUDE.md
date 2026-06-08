# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository

Single-script Bash utility for updating developer machines on Debian/Ubuntu/elementaryOS or openSUSE. Entry point: `system-update.sh`.

## Usage

```
./system-update.sh           # daily: package manager updates only (apt/zypper/snap/flatpak)
./system-update.sh --full    # weekly: also runs language toolchains updates + cleanup/pruning
```

## Architecture

The script is a flat collection of `update_<tool>` and `cleanup_<tool>` / `prune_<tool>` functions, each guarded by `command -v <tool>` so missing tools are silently skipped. Execution order at the bottom of the file controls daily vs `--full` behavior:

- Always runs: `update_apt`, `update_zypper`, `update_snap`, `update_flatpak`, `update_fwupd` (firmware: refresh + list only, never auto-flashes).
- `--full` / `-f` adds, in order: `cleanup_apt`, then language/runtime updates (`update_tldr`, `update_vscode`, `update_npm`, `update_pipx`, `update_pyenv`, `update_asdf`, `update_devbox`, `update_claude`, `update_composer`, `update_cargo`, `update_uv`), then disk-space reclaim (`cleanup_zypper`, `cleanup_flatpak`, `cleanup_logs`, `cleanup_snapper`, `prune_docker`, `prune_uv`, `prune_caches`).
- Trailing block prints a reboot hint if `/var/run/reboot-required` exists, and a `fortune -s` if available.

`prune_caches` is interactive — it prompts before deleting cache dirs that belong to tools no longer installed. The mapping lives in the `command_cache` associative array; add new entries there when extending.

## Conventions when adding tools

- Add a `command -v` guard so the function no-ops when the tool is absent.
- Echo a `>>> Updating <thing>...` banner for consistency with existing output.
- Place daily-safe package-manager updates in the unconditional section; place slow/aggressive ops under the `--full` block.
- Update the Tools list in `README.md`.
