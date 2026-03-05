# .dotfiles

Personal dotfiles with a component-based architecture and interactive TUI manager.

## Quick Start

```bash
git clone https://github.com/miferco97/.dotfiles.git $HOME/.dotfiles
cd $HOME/.dotfiles
./setup.bash
```

The TUI auto-installs its own prerequisites (gum, python3, pip, pyyaml) on first run.

## Components

| Component | Description | Requires |
|-----------|-------------|----------|
| **essentials** | git, curl | -- |
| **nvim** | NeoVim, Node.js 20, Nerd Fonts, ripgrep, xclip, C++ tools | essentials |
| **tmux** | tmux, hstr, powerline, tpm | essentials |
| **bash** | Shell config (aliases, bashrc extension via `~/.bashrc.d`) | -- |
| **docker** | Docker Engine, NVIDIA Container Toolkit (if GPU detected) | essentials |
| **claude** | Claude Code notification daemon (GNOME + PipeWire) | essentials |

Each component lives in `components/<name>/` with:
- `deps.yaml` -- manifest (name, order, requires, check, apt/pip/ppa deps, symlink target)
- `setup.bash` -- post-install script (optional)
- `uninstall.bash` -- cleanup script (optional)
- `config/` -- files symlinked into `$HOME` (optional)

## TUI Manager

`./setup.bash` provides an interactive menu:

- **Install** -- select components to install (all pre-selected, installed ones grayed out)
- **Uninstall** -- remove components (symlinks, cleanup scripts, optionally apt packages)
- **Reinstall** -- full re-install (unlink + install)
- **Update** -- re-run setup scripts and refresh symlinks for installed components
- **Refresh status** -- rescan and display component + symlink health

Dependencies between components are resolved automatically. Symlink issues are flagged in the status display.

## Symlink Manager

```bash
python3 install.py                        # create all symlinks
python3 install.py --dry-run              # preview
python3 install.py --unlink               # remove all symlinks
python3 install.py --only bash,claude     # filter to specific components
```

Existing files are backed up to `*.bak` before overwriting.

## NeoVim

Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim). Config entry point: `components/nvim/config/init.lua`.

**LSP servers** (auto-installed via mason.nvim): lua_ls, pyright, clangd, bashls, ts_ls, marksman

**Formatters**: stylua (Lua), ruff (Python), beautysh (Bash), clang-format/ament_uncrustify (C/C++)

### Vimspector (Debugging)

Add a `.vimspector.json` to your project root. Example for C++:
```json
{
  "configurations": {
    "Launch": {
      "adapter": "vscode-cpptools",
      "configuration": {
        "request": "launch",
        "program": "./build/your_binary",
        "cwd": "${workspaceFolder}",
        "externalConsole": true,
        "MIMode": "gdb"
      }
    }
  }
}
```

> Vimspector does not compile your code -- compile before debugging.

## Troubleshooting

**C++ autocompletion fails with std libs:**
```bash
sudo apt install libstdc++-12-dev
```
See [this post](https://stackoverflow.com/questions/74785927/clangd-doesnt-recognize-standard-headers) for details.

**Logs:** All setup output is written to `~/.dotfiles-install.log`.
