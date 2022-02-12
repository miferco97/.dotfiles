# My .dotfiles
For setting up the configuration of :
- NeoVim
- Tmux
- Zsh
- i3 (in progress)

## Setup steps:

1. Clone the repository into ```~/.dotfiles```

```
$ git clone https://github.com/miferco97/.dotfiles.git $HOME/.dotfiles 
```

Run the following commands: 
```
$ cd ~/.dotfiles
$ bash core_setup.bash # Download and install Neovim, Tmux, Zsh and i3

Reload a new terminal
$ cd ~/.dotfiles
$ zsh plugin_setup.zsh # Install nvim plugins
```

## Coc languages Servers

For installing basic languages run the desired command into nvim:

> C++ language server

```
:CocInstall coc-clangd
``` 

> Python language server
```
:CocInstall coc-pyright
``` 
