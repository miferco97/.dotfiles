#!/bin/bash

if [[ -z $STOW_FOLDERS ]]; then
    STOW_FOLDERS="nvim/.config/,zsh,tmux"
fi

if [[ -z $DOTFILES ]]; then
    DOTFILES=$HOME/.dotfiles
fi

STOW_FOLDERS=$STOW_FOLDERS DOTFILES=$DOTFILES $DOTFILES/setup_scripts/install.bash
