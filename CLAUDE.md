# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managing NeoVim, Tmux, Bash, Docker, and Claude Code configurations. Uses a component-based architecture with a gum-powered TUI manager.

## Installation & Deployment

```bash
# Interactive TUI manager (gum-based)
# Provides: Install, Uninstall, Reinstall, Update, Status
./setup.bash

# Non-interactive fallback (installs everything)
./env_setup.bash

# Deploy/manage symlinks only
python3 install.py                          # create symlinks
python3 install.py --dry-run                # preview changes
python3 install.py --unlink                 # remove symlinks
python3 install.py --only bash,claude       # filter to specific components
python3 install.py --unlink --only nvim     # remove symlinks for one component
```

## Repository Structure

```
components/
  essentials/          # git, curl (order: 0)
  nvim/                # NeoVim + tools, fonts, Node.js (order: 2, requires: essentials)
    config/            # NeoVim config (lazy.nvim plugin manager)
  tmux/                # tmux, hstr, powerline, tpm (order: 3, requires: essentials)
    config/            # .tmux.conf (Ctrl-A prefix)
  bash/                # Bash config (order: 4)
    config/            # bashrc_extension, aliases
  docker/              # Docker Engine, NVIDIA toolkit (order: 5, requires: essentials)
  claude/              # Claude Code notification hooks (order: 6, requires: essentials)
    config/            # Notification daemon scripts
docs/                  # Claude hooks documentation
setup.bash             # Gum TUI entry point (auto-bootstraps gum, python3, pip, pyyaml)
env_setup.bash         # Non-interactive fallback
install.py             # Symlink manager (reads deps.yaml files)
```

Each component has:
- `deps.yaml` -- manifest with name, order, requires, check command, apt/pip/ppa deps, and symlink target
- `setup.bash` (optional) -- post-install logic that can't be expressed as package lists
- `uninstall.bash` (optional) -- cleanup logic for uninstall (e.g., remove autostart entries, group membership)
- `config/` (optional) -- config files to symlink into $HOME

## TUI Manager (setup.bash)

The main menu provides:
- **Install** -- select components to install (installed ones shown grayed out, missing pre-selected)
- **Uninstall** -- select installed components to remove (warns about dependency conflicts)
- **Reinstall** -- full re-install of any component (unlinks + installs)
- **Update** -- re-run setup scripts + relink for installed components
- **Refresh status** -- rescan component and symlink status

Features:
- Auto-bootstrap: detects and installs missing prerequisites (gum, python3, pip, pyyaml) with a single prompt
- Dependency ordering: components sorted by `order` field, auto-selects dependencies
- Symlink validation: warns about missing, broken, or wrong-target symlinks in status display
- Error recovery: per-component failure handling with continue prompt
- Logging: all output to `~/.dotfiles-install.log` with timestamps

## NeoVim Architecture

- **Entry point:** `components/nvim/config/init.lua` -- loads personal config, bootstraps lazy.nvim
- **Personal config:** `lua/personal/` -- `init.lua` (autocmds, filetypes), `sets.lua` (editor options), `remap.lua` (keybindings, leader=space)
- **Plugins:** `lua/plugins/` -- each file is a lazy.nvim plugin spec, auto-loaded by lazy.nvim
- **LSP:** mason.nvim auto-installs servers (lua_ls, pyright, clangd, bashls, ts_ls, marksman)
- **Formatting:** conform.nvim with stylua, ruff, beautysh, clang-format/ament_uncrustify
- **C++/ROS2 focus:** ament_uncrustify formatter, `.launch` file detection, cpplint/cppcheck linting

## Claude Code Notification System

The `components/claude/config/` directory contains a daemon-based notification system:
- A Python daemon watches `~/.claude/hook-events/` for JSON event files
- Uses GApplication (Gio) for GNOME notifications, PipeWire (pw-play) for sounds
- Deployed via `components/claude/setup.bash`
- See `docs/claude-hooks-guide.md` for architecture details
