# Neovim Keybindings Cheatsheet

Leader key: `<Space>`

## General

| Key | Action |
|-----|--------|
| `jj` | Exit insert mode (Escape) |
| `<leader>+` | Increase window width |
| `<leader>-` | Decrease window width |
| `Y` | Yank to end of line |
| `n` / `N` | Next/prev search (centered) |
| `<C-o>` / `<C-i>` | Jump back/forward (centered) |
| `<leader><C-n>` | Clear search highlight |
| `<C-h/j/k/l>` | Navigate between windows |

## Clipboard

| Key | Action |
|-----|--------|
| `<leader>y` | Yank to system clipboard |
| `<leader>Y` | Yank line to system clipboard |
| `<leader>p` | Paste without overwriting register (visual) |
| `<leader>d` | Delete to black hole register |

## File Navigation (Telescope)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<C-p>` | Git files |
| `fg` | Live grep |
| `<leader>fs` | Grep with prompt |
| `<leader>fw` | Grep word under cursor |

## Harpoon

| Key | Action |
|-----|--------|
| `<C-a>` | Add file to harpoon |
| `<C-e>` | Toggle harpoon menu |
| `<C-n>` | Next harpoon file |

## LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `gl` | Line diagnostics |
| `K` | Hover documentation |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>o` | Switch header/source (C/C++) |
| `<leader>th` | Toggle inlay hints |
| `<leader>tv` | Toggle virtual text |
| `<leader>tk` | Toggle auto hover (on by default) |

## Trouble (Diagnostics)

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xs` | Symbols |
| `<leader>xl` | LSP definitions/refs |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |

## Debugging (Vimspector)

| Key | Action |
|-----|--------|
| `<leader>db` | Launch debugger |
| `<leader>dx` | Reset debugger |
| `<leader>de` | Eval |
| `<leader>dw` | Watch |
| `<leader>do` | Show output |
| `<leader>di` | Balloon eval |
| `<F9>` | Toggle breakpoint |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<S-F11>` | Step out |
| `<F6>` | Pause |
| `<S-F5>` | Stop |
| `<C-S-F5>` | Restart |

## Claude Code

| Key | Action |
|-----|--------|
| `<leader>ac` | Toggle Claude |
| `<leader>af` | Focus Claude |
| `<leader>ar` | Resume Claude |
| `<leader>aC` | Continue Claude |
| `<leader>am` | Select model |
| `<leader>ab` | Add current buffer |
| `<leader>as` | Send to Claude (visual) |
| `<leader>aa` | Accept diff |
| `<leader>ad` | Deny diff |

## Other

| Key | Action |
|-----|--------|
| `<leader>pv` | Open netrw explorer |
| `<leader>gs` | Git status (Fugitive) |
| `<leader>cf` | Format code |
| `<C-t>` | Toggle terminal |
| `<F5>` | Toggle undo tree |
| `:Trex` | Toggle NvimTree |

## Terminal Mode

| Key | Action |
|-----|--------|
| `<Esc>` | Exit terminal mode |
| `jj` | Exit terminal mode |
