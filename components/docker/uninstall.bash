#!/bin/bash
set -e

# Remove user from docker group
if groups "$USER" | grep -q docker; then
    sudo gpasswd -d "$USER" docker 2>/dev/null || true
    echo "Removed $USER from docker group."
fi

echo "Docker uninstalled."
