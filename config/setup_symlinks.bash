#!/bin/bash

if [[ -z $STOW_FOLDERS ]]; then
    STOW_FOLDERS="nvim/.config/,tmux"
fi

if [[ -z $DOTFILES ]]; then
    DOTFILES=$HOME/.dotfiles/config
fi

STOW_FOLDERS=$STOW_FOLDERS DOTFILES=$DOTFILES $DOTFILES/install.bash
