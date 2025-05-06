#!/bin/bash

SCRIPTS=$(find $(dirname $0)/setup_scripts -name "*.setup.bash")
# sort the names of the scripts
SCRIPTS=$(echo "$SCRIPTS" | sort)

for script in $SCRIPTS; do
    echo "Running setup script: $script"
    bash $script
    if [ $? -ne 0 ]; then
        echo "Error running setup script: $script"
        exit 1
    fi
done
