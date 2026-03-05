#!/bin/bash
set -e

# Install Node.js 20 (needed for LSP servers)
NODE_MAJOR=20
if command -v node &> /dev/null; then
    echo "Node.js is already installed."
else
    echo "Installing Node.js $NODE_MAJOR..."
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt-get update
    sudo apt-get install nodejs -y
fi

# Install Nerd Fonts
FONTS=("JetBrainsMono" "Hack")
for FONT in "${FONTS[@]}"; do
    if fc-list | grep -i "$FONT" > /dev/null; then
        echo "$FONT is already installed."
    else
        echo "Installing $FONT..."
        mkdir -p ~/.local/share/fonts
        wget -P ~/.local/share/fonts "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/${FONT}.zip"
        if [ $? -ne 0 ]; then
            echo "Failed to download $FONT. Skipping."
            continue
        fi
        pushd ~/.local/share/fonts
        unzip "${FONT}.zip"
        rm "${FONT}.zip"
        popd
        fc-cache -fv
    fi
done

echo "NeoVim setup complete."
