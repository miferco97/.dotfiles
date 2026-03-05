#!/bin/bash
set -e

# Ensure ~/.bashrc.d is sourced from ~/.bashrc
BASHRC_D_BLOCK='# Source all files in ~/.bashrc.d
if [ -d ~/.bashrc.d ]; then
    for f in ~/.bashrc.d/*; do
        [ -f "$f" ] && source "$f"
    done
fi'

if ! grep -q 'bashrc.d' ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "$BASHRC_D_BLOCK" >> ~/.bashrc
    echo "Added ~/.bashrc.d sourcing to ~/.bashrc"
else
    echo "~/.bashrc.d sourcing already present in ~/.bashrc"
fi

echo "Bash config setup complete."
