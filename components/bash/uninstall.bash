#!/bin/bash
set -e

# Remove the bashrc.d sourcing block from ~/.bashrc
if grep -q 'bashrc.d' ~/.bashrc 2>/dev/null; then
    # Remove the sourcing block (comment + if block)
    sed -i '/# Source all files in ~\/.bashrc.d/,/^fi$/d' ~/.bashrc
    # Remove any trailing blank lines left behind
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' ~/.bashrc
    echo "Removed ~/.bashrc.d sourcing from ~/.bashrc"
fi

echo "Bash config uninstalled."
