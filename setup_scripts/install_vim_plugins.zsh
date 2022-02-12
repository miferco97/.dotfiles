#!/bin/zsh

source ~/.zsh_profile
sudo apt install build-essential python3-dev

# install vim-plug
sh -c "curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

#for copilot we need to install node js 12 or superior
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

# install pulgins in nvim
nvim +'PlugInstall --sync' +qa

