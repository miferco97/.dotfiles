#!/bin/bash

#install curl and tmux
sudo apt install curl tmux -y

# install zsh
sudo apt install zsh -y && \ 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \ 
sudo apt-get install fonts-powerline -y && \
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k && \
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
zsh -c 'print zsh installed correctly :D; zsh -i' 

# install nvim
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
pip3 install pynvim
