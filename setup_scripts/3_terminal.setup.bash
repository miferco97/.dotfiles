#!/bin/bash

pip install --user --break-system-packages powerline-status
sudo apt install hstr -y 

LINE_FOR_BASHRC='source ~/.dotfiles/config/bash/bashrc_extension'

# Check if the line already exists in .bashrc
# If it does not exist, append it to the end of the file

if ! grep -q "$LINE_FOR_BASHRC" ~/.bashrc; then
    echo "$LINE_FOR_BASHRC" >> ~/.bashrc
fi

sudo apt-get install tmux tmuxinator -y

# check if tpm is not installed
if [ ! -d ~/.tmux/plugins/tpm ]; then
    echo "Installing tpm..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "tpm already installed"
fi

