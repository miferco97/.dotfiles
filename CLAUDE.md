# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managing NeoVim, Tmux, Bash, and Claude Code configurations. Configs are deployed via symlinks, not GNU stow.

## Installation & Deployment

```bash
# Full setup (runs all numbered scripts in order)
./env_setup.bash

# Deploy symlinks only
cd config && ./setup_symlinks.bash
```

- `env_setup.bash` runs `setup_scripts/0_essentials.setup.bash` through `5_claude_hooks.setup.bash` sequentially
- `config/install.bash` handles symlink creation; controlled by `STOW_FOLDERS` env var (default: `"nvim/.config/,tmux"`)
- Bash config is sourced via a line appended to `~/.bashrc`: `source ~/.dotfiles/config/bash/bashrc_extension`

## Repository Structure

```
config/
  nvim/.config/nvim/    # NeoVim config (lazy.nvim plugin manager)
  tmux/.tmux.conf       # Tmux config (Ctrl-A prefix, tpm plugins)
  bash/                 # bashrc_extension, aliases
  claude/.claude/hooks/ # Desktop notification scripts for Claude Code events
setup_scripts/          # Numbered 0-5, each handles one component
docs/                   # Claude hooks documentation
```

## NeoVim Architecture

- **Entry point:** `config/nvim/.config/nvim/init.lua` — loads personal config, bootstraps lazy.nvim
- **Personal config:** `lua/personal/` — `init.lua` (autocmds, filetypes), `sets.lua` (editor options), `remap.lua` (keybindings, leader=space)
- **Plugins:** `lua/plugins/` — each file is a lazy.nvim plugin spec, auto-loaded by lazy.nvim
- **LSP:** mason.nvim auto-installs servers (lua_ls, pyright, clangd, bashls, ts_ls, marksman)
- **Formatting:** conform.nvim with stylua, ruff, beautysh, clang-format/ament_uncrustify
- **C++/ROS2 focus:** ament_uncrustify formatter, `.launch` file detection, cpplint/cppcheck linting

## Claude Code Notification System

The `config/claude/.claude/hooks/` directory contains a daemon-based notification system:
- A Python daemon watches `~/.claude/hook-events/` for JSON event files
- Uses GApplication (Gio) for GNOME notifications, PipeWire (pw-play) for sounds
- Deployed via `setup_scripts/5_claude_hooks.setup.bash`
- See `docs/claude-hooks-guide.md` for architecture details
