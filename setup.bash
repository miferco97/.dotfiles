#!/bin/bash

sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo apt-get install fonts-powerline
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

# install nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage

# install vim-plug
#curl -fLo ~/.var/app/io.neovim.nvim/data/nvim/site/autoload/plug.vim --create-dirs \
#   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

#sudo apt install build-essential cmake3 python3-dev

git clone https://github.com/VundleVim/Vundle.vim.git ./nvim/.config/nvim/bundle/Vundle.vim

#python3 install.py --clangd-completer


