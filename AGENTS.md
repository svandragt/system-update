# AGENTS.md

## Repository

This repository contains a single-script Bash utility for updating developer
machines running Debian, Ubuntu, elementary OS, or openSUSE. The entry point is
`system-update.sh`.

## Usage

```sh
./system-update.sh           # Daily package-manager updates
./system-update.sh --full    # Broader updates and cleanup
```

## Architecture

The script is a flat collection of `update_<tool>` and `cleanup_<tool>` or
`prune_<tool>` functions. Each function is guarded by `command -v <tool>` so
tools that are not installed are silently skipped. The execution order at the
bottom of the file controls daily versus `--full` behavior.

- Always runs: `update_apt`, `update_zypper`, `update_snap`, `update_flatpak`,
  and `update_fwupd`. The firmware step refreshes metadata and lists updates;
  it never flashes firmware automatically.
- `--full` or `-f` runs, in order: `cleanup_apt`; language and runtime updates
  (`update_tldr`, `update_vscode`, `update_npm`, `update_pipx`, `update_pyenv`,
  `update_asdf`, `update_devbox`, `update_claude`, `update_composer`,
  `update_cargo`, and `update_uv`); then disk-space reclamation
  (`cleanup_zypper`, `cleanup_flatpak`, `cleanup_logs`, `cleanup_snapper`,
  `prune_docker`, `prune_uv`, and `prune_caches`).
- The trailing block prints a reboot hint when `/var/run/reboot-required`
  exists and a short fortune when `fortune` is available.

`prune_caches` is interactive. It prompts before deleting cache directories
that belong to tools that are no longer installed. Add new cache mappings to
its `command_cache` associative array.

## Conventions

- Guard tool-specific functions with `command -v` so they no-op when the tool
  is absent.
- Print a `>>> Updating <thing>...` or equivalent banner consistent with the
  existing output.
- Put daily-safe package-manager updates in the unconditional execution block.
- Put slow, broad, or destructive maintenance under the `--full` block.
- Update the Tools list in `README.md` when adding support for a tool.
- Keep the implementation compatible with Bash; the script uses Bash-specific
  features such as associative arrays and `[[ ... ]]`.

## Verification

At minimum, syntax-check changes with:

```sh
bash -n system-update.sh
```

Do not run the update script merely as a test: it invokes package managers,
uses `sudo`, updates installed tools, and can delete caches in `--full` mode.
