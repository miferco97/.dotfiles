# My .dotfiles
For setting up the configuration of :
- NeoVim (https://neovim.io/)
- Tmux (http://www.sromero.org/wiki/linux/aplicaciones/tmux)
- Zsh with OhMyZsh (https://ohmyz.sh/ )
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

>[INFO] My zsh theme is powerlevel10k, if you want to use the recommended fonts follow this instructions: https://github.com/romkatv/powerlevel10k#fonts

## Coc languages Servers

For installing basic languages run the desired command into nvim:

> C++ language server

```
:CocInstall coc-clangd
:CocCommand clangd.install
``` 

> Python language server
```
:CocInstall coc-pyright
``` 
