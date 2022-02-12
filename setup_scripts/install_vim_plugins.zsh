#!/bin/zsh

source ~/.zsh_profile
sudo apt install build-essential python3-dev

# install Vundle plugin manager
# git clone https://github.com/VundleVim/Vundle.vim.git ./nvim/.config/nvim/bundle/Vundle.vim

#pushd $HOME/.vim/bundle/YouCompleteMe
#python3 install.py --clangd-completer
#popd 

# install vim-plug
curl -fLo ~/.dotfiles/nvim/.config/nvim/site/autoload/plug.vim --create-dirs \
   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

#for copilot we need to install node js 12 or superior
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

# install pulgins in nvim
nvim +'PlugInstall --sync' +qa

