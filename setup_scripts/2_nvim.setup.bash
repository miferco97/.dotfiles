#!/bin/bash

# install nvim
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get update
sudo apt-get install \
	neovim \
	xclip \
	ripgrep \
	python3-pynvim \
	-y

# install node 20 
# NODE JS and PYNVIM for use nvim

NODE_MAJOR=20
# check if node is already installed
if command -v node &> /dev/null; then
    echo "Node is already installed."
else
    echo "Node is not installed. Installing..."
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt-get install nodejs -y
fi

sudo apt-get install cpplint cppcheck -y
sudo apt-get install cmake-format -y

# fonts

# check if there are installed 
FONTS=("JetBrainsMono" "Hack")

for FONT in "${FONTS[@]}"; do
    if fc-list | grep -i "$FONT" > /dev/null; then
        echo "$FONT is already installed."
    else
        echo "$FONT is not installed. Installing..."
        # Install the font here
        wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/${FONT}.zip 
        if [ $? -ne 0 ]; then
            echo "Failed to download $FONT. Exiting."
            continue
        fi
        pushd ~/.local/share/fonts
        unzip ${FONT}.zip
        rm ${FONT}.zip
        popd
        fc-cache -fv
    fi
done

