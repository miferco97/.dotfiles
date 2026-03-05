#!/bin/bash
# Non-interactive fallback: installs ALL components in order.
# For interactive selection, use ./setup.bash instead.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPONENTS_DIR="$REPO_DIR/components"

# Define install order
ORDERED_COMPONENTS=(essentials python nvim tmux bash docker claude)

parse_yaml_list() {
    local file="$1" field="$2"
    awk -v field="$field:" '
        $0 ~ "^"field { found=1; next }
        found && /^  - / { gsub(/^  - /, ""); print; next }
        found && /^[^ ]/ { found=0 }
    ' "$file"
}

parse_yaml_field() {
    local file="$1" field="$2"
    grep "^${field}:" "$file" 2>/dev/null | sed "s/^${field}:[[:space:]]*//"
}

all_apt=()
all_pip=()
all_ppa=()

# Collect all dependencies
for comp in "${ORDERED_COMPONENTS[@]}"; do
    deps_file="$COMPONENTS_DIR/$comp/deps.yaml"
    [ -f "$deps_file" ] || continue

    while IFS= read -r ppa; do
        [ -n "$ppa" ] && all_ppa+=("$ppa")
    done < <(parse_yaml_list "$deps_file" "ppa")

    while IFS= read -r pkg; do
        [ -n "$pkg" ] && all_apt+=("$pkg")
    done < <(parse_yaml_list "$deps_file" "apt")

    while IFS= read -r pkg; do
        [ -n "$pkg" ] && all_pip+=("$pkg")
    done < <(parse_yaml_list "$deps_file" "pip")
done

# Add PPAs
for ppa in "${all_ppa[@]}"; do
    echo "Adding PPA: $ppa"
    sudo add-apt-repository "$ppa" -y
done

# Batch apt install
if [ ${#all_apt[@]} -gt 0 ]; then
    unique_apt=($(printf '%s\n' "${all_apt[@]}" | sort -u))
    echo "Installing apt packages: ${unique_apt[*]}"
    sudo apt-get update
    sudo apt-get install -y "${unique_apt[@]}"
fi

# Batch pip install
if [ ${#all_pip[@]} -gt 0 ]; then
    unique_pip=($(printf '%s\n' "${all_pip[@]}" | sort -u))
    echo "Installing pip packages: ${unique_pip[*]}"
    pip install --user --break-system-packages "${unique_pip[@]}"
fi

# Run post-install scripts in order
for comp in "${ORDERED_COMPONENTS[@]}"; do
    setup_script="$COMPONENTS_DIR/$comp/setup.bash"
    if [ -f "$setup_script" ]; then
        name="$(parse_yaml_field "$COMPONENTS_DIR/$comp/deps.yaml" "name")"
        echo ""
        echo "=== Post-install: $name ==="
        bash "$setup_script"
    fi
done

# Create symlinks
echo ""
echo "=== Creating symlinks ==="
python3 "$REPO_DIR/install.py"

echo ""
echo "All components installed. Reboot recommended."
