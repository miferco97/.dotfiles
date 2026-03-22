#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPONENTS_DIR="$REPO_DIR/components"
LOG_FILE="$HOME/.dotfiles-install.log"

# --- Colors (fallback when gum is unavailable) ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Logging ---
log_init() {
    echo "=== dotfiles setup $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"
}

log() {
    local level="$1"; shift
    local msg="$*"
    echo "$(date '+%H:%M:%S') [$level] $msg" >> "$LOG_FILE"
    gum log --level "$level" "$msg"
}

# --- Bootstrap dependencies ---
bootstrap_deps() {
    local need_apt=()
    local need_pip=()
    local need_gum=false

    if ! command -v gum &> /dev/null; then
        need_gum=true
    fi

    if ! command -v python3 &> /dev/null; then
        need_apt+=(python3 python-is-python3 python3-pip)
    else
        if ! command -v pip &> /dev/null && ! command -v pip3 &> /dev/null; then
            need_apt+=(python3-pip)
        fi
    fi

    if command -v python3 &> /dev/null && ! python3 -c "import yaml" &> /dev/null; then
        need_pip+=(pyyaml)
    fi

    # Nothing to do
    if [ "$need_gum" = false ] && [ ${#need_apt[@]} -eq 0 ] && [ ${#need_pip[@]} -eq 0 ]; then
        return 0
    fi

    echo -e "${BOLD}The following dependencies are needed to run the dotfiles manager:${NC}"
    echo ""
    if [ "$need_gum" = true ]; then
        echo -e "  ${CYAN}gum${NC} (interactive TUI framework)"
    fi
    for pkg in "${need_apt[@]}"; do
        echo -e "  ${CYAN}${pkg}${NC} (apt)"
    done
    for pkg in "${need_pip[@]}"; do
        echo -e "  ${CYAN}${pkg}${NC} (pip)"
    done
    echo ""
    read -p "Install these dependencies? [Y/n] " yn
    case "$yn" in
        [nN]*) echo "Cannot proceed without dependencies."; exit 1 ;;
    esac

    # Install gum
    if [ "$need_gum" = true ]; then
        echo -e "${CYAN}Installing gum...${NC}"
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        need_apt+=(gum)
    fi

    # Install apt packages
    if [ ${#need_apt[@]} -gt 0 ]; then
        echo -e "${CYAN}Installing apt packages...${NC}"
        sudo apt-get update && sudo apt-get install -y "${need_apt[@]}"
    fi

    # Install pip packages (after python3/pip are available)
    if [ ${#need_pip[@]} -gt 0 ]; then
        echo -e "${CYAN}Installing pip packages...${NC}"
        pip install --user --break-system-packages "${need_pip[@]}" 2>/dev/null || pip install --user "${need_pip[@]}"
    fi

    # Also check pyyaml again if python3 was just installed
    if ! python3 -c "import yaml" &> /dev/null; then
        echo -e "${CYAN}Installing PyYAML...${NC}"
        pip install --user --break-system-packages pyyaml 2>/dev/null || pip install --user pyyaml
    fi

    # Verify everything
    local failed=false
    command -v gum &> /dev/null || { echo -e "${RED}Failed to install gum.${NC}"; failed=true; }
    command -v python3 &> /dev/null || { echo -e "${RED}Failed to install python3.${NC}"; failed=true; }
    python3 -c "import yaml" &> /dev/null || { echo -e "${RED}Failed to install PyYAML.${NC}"; failed=true; }
    if [ "$failed" = true ]; then
        echo "Cannot proceed. Please install missing dependencies manually."
        exit 1
    fi
}

bootstrap_deps

# --- Multi-select helper ---
# gum choose --no-limit returns empty when user presses enter without toggling.
# This wrapper retries with --limit 1 (single-select) so enter picks the highlighted item.
gum_choose_multi() {
    local result
    result=$(gum choose --no-limit "$@")
    if [ -z "$result" ]; then
        result=$(gum choose --limit 1 "$@")
    fi
    echo "$result"
}

# --- YAML parsing helpers ---
parse_yaml_field() {
    local file="$1" field="$2"
    grep "^${field}:" "$file" 2>/dev/null | sed "s/^${field}:[[:space:]]*//"
}

parse_yaml_list() {
    local file="$1" field="$2"
    awk -v field="$field:" '
        $0 ~ "^"field { found=1; next }
        found && /^  - / { gsub(/^  - /, ""); print; next }
        found && /^[^ ]/ { found=0 }
    ' "$file"
}

# --- Component discovery ---
declare -a COMP_NAMES COMP_DIRS COMP_CHECKS COMP_STATUS COMP_ORDERS COMP_SLUGS COMP_LINK_STATUS
declare -A COMP_REQUIRES  # slug -> space-separated list of required slugs

discover_components() {
    COMP_NAMES=(); COMP_DIRS=(); COMP_CHECKS=(); COMP_STATUS=(); COMP_ORDERS=(); COMP_SLUGS=(); COMP_LINK_STATUS=()
    COMP_REQUIRES=()

    # Collect components with their order
    local -a unsorted_slugs=()
    local -A slug_order=()
    local -A slug_dir=()

    for comp_dir in "$COMPONENTS_DIR"/*/; do
        local deps_file="$comp_dir/deps.yaml"
        [ -f "$deps_file" ] || continue

        local slug
        slug="$(basename "$comp_dir")"
        local order
        order="$(parse_yaml_field "$deps_file" "order")"
        [ -z "$order" ] && order=99

        unsorted_slugs+=("$slug")
        slug_order["$slug"]="$order"
        slug_dir["$slug"]="$comp_dir"
    done

    # Sort by order
    local -a sorted_slugs
    sorted_slugs=($(for s in "${unsorted_slugs[@]}"; do echo "${slug_order[$s]} $s"; done | sort -n | awk '{print $2}'))

    local i=0
    for slug in "${sorted_slugs[@]}"; do
        local comp_dir="${slug_dir[$slug]}"
        local deps_file="$comp_dir/deps.yaml"

        COMP_SLUGS[$i]="$slug"
        COMP_DIRS[$i]="$comp_dir"
        COMP_NAMES[$i]="$(parse_yaml_field "$deps_file" "name")"
        COMP_CHECKS[$i]="$(parse_yaml_field "$deps_file" "check")"
        COMP_ORDERS[$i]="${slug_order[$slug]}"

        # Parse requires
        local reqs=""
        while IFS= read -r req; do
            [ -n "$req" ] && reqs="$reqs $req"
        done < <(parse_yaml_list "$deps_file" "requires")
        COMP_REQUIRES["$slug"]="${reqs# }"

        # Check install status
        if [ -n "${COMP_CHECKS[$i]}" ] && eval "${COMP_CHECKS[$i]}" &> /dev/null; then
            COMP_STATUS[$i]="installed"
        else
            COMP_STATUS[$i]="missing"
        fi

        # Check symlink status
        local link_target
        link_target="$(parse_yaml_field "$deps_file" "link")"
        if [ -n "$link_target" ]; then
            local target="$HOME/$link_target"
            local source="$comp_dir/config"
            # Resolve single-file links
            local target_name
            target_name="$(basename "$link_target")"
            local candidate="$source/$target_name"
            if [ -f "$candidate" ]; then
                source="$candidate"
            fi

            if [ -L "$target" ]; then
                local actual
                actual="$(readlink -f "$target")"
                local expected
                expected="$(readlink -f "$source")"
                if [ "$actual" = "$expected" ]; then
                    COMP_LINK_STATUS[$i]="ok"
                else
                    COMP_LINK_STATUS[$i]="wrong:$actual"
                fi
            elif [ -e "$target" ]; then
                COMP_LINK_STATUS[$i]="not-symlink"
            else
                COMP_LINK_STATUS[$i]="missing"
            fi
        else
            COMP_LINK_STATUS[$i]=""
        fi
        i=$((i + 1))
    done
}

# --- Display status table ---
show_status() {
    echo ""
    gum style --border normal --padding "0 1" --border-foreground 212 \
        "$(gum style --bold 'Component Status')"
    echo ""

    for i in "${!COMP_NAMES[@]}"; do
        local name="${COMP_NAMES[$i]}"
        local status="${COMP_STATUS[$i]}"
        local link_status="${COMP_LINK_STATUS[$i]}"
        local line=""

        if [ "$status" = "installed" ]; then
            line="  $(gum style --foreground 46 "✓") $name"
        else
            line="  $(gum style --foreground 196 "✗") $name"
        fi

        # Append symlink warnings
        if [ -n "$link_status" ] && [ "$link_status" != "ok" ] && [ "$link_status" != "" ]; then
            case "$link_status" in
                missing)
                    line="$line  $(gum style --foreground 214 "⚠ symlink missing")"
                    ;;
                not-symlink)
                    line="$line  $(gum style --foreground 196 "⚠ exists but not a symlink")"
                    ;;
                wrong:*)
                    local actual="${link_status#wrong:}"
                    line="$line  $(gum style --foreground 196 "⚠ symlink points to wrong target: $actual")"
                    ;;
            esac
        fi

        echo "$line"
    done
    echo ""
}

# --- Dependency resolution ---
# Given a newline-separated list of selected names, auto-add required dependencies
resolve_dependencies() {
    local chosen="$1"
    local resolved="$chosen"
    local added=()

    for i in "${!COMP_NAMES[@]}"; do
        local name="${COMP_NAMES[$i]}"
        local slug="${COMP_SLUGS[$i]}"

        # Skip if not selected
        echo "$chosen" | grep -qF "$name" || continue

        # Check each requirement
        for req_slug in ${COMP_REQUIRES[$slug]}; do
            # Find the required component's name
            for j in "${!COMP_SLUGS[@]}"; do
                if [ "${COMP_SLUGS[$j]}" = "$req_slug" ]; then
                    local req_name="${COMP_NAMES[$j]}"
                    if ! echo "$resolved" | grep -qF "$req_name"; then
                        resolved="$req_name"$'\n'"$resolved"
                        added+=("$req_name (required by $name)")
                    fi
                    break
                fi
            done
        done
    done

    # Inform about auto-selections
    for note in "${added[@]}"; do
        log info "Auto-selected: $note"
    done

    echo "$resolved"
}

# --- Get indices for chosen component names ---
get_selected_indices() {
    local chosen="$1"
    local indices=()

    # Return in dependency order (already sorted by COMP_ORDERS)
    for i in "${!COMP_NAMES[@]}"; do
        local name="${COMP_NAMES[$i]}"
        if echo "$chosen" | grep -qF "$name"; then
            indices+=("$i")
        fi
    done
    echo "${indices[@]}"
}

# --- Install packages and run setup for selected indices ---
run_install() {
    local indices=("$@")
    local all_apt=() all_pip=() all_ppa=()
    local start_time=$SECONDS
    local failed=() succeeded=()

    # Collect packages
    for i in "${indices[@]}"; do
        local deps_file="${COMP_DIRS[$i]}/deps.yaml"

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
    if [ ${#all_ppa[@]} -gt 0 ]; then
        log info "Adding PPAs..."
        for ppa in "${all_ppa[@]}"; do
            log info "Adding $ppa..."
            sudo add-apt-repository "$ppa" -y >> "$LOG_FILE" 2>&1
        done
    fi

    # Batch apt install
    if [ ${#all_apt[@]} -gt 0 ]; then
        log info "Installing apt packages..."
        local unique_apt=($(printf '%s\n' "${all_apt[@]}" | sort -u))
        echo "  Packages: ${unique_apt[*]}"
        gum spin --title "apt-get update" -- sudo apt-get update
        if ! sudo apt-get install -y "${unique_apt[@]}"; then
            log error "Some apt packages failed to install"
            if ! gum confirm "Continue anyway?"; then
                return 1
            fi
        fi
    fi

    # Batch pip install
    if [ ${#all_pip[@]} -gt 0 ]; then
        log info "Installing pip packages..."
        local unique_pip=($(printf '%s\n' "${all_pip[@]}" | sort -u))
        echo "  Packages: ${unique_pip[*]}"
        if ! pip install --user --break-system-packages "${unique_pip[@]}"; then
            log error "Some pip packages failed to install"
            if ! gum confirm "Continue anyway?"; then
                return 1
            fi
        fi
    fi

    # Run post-install scripts
    for i in "${indices[@]}"; do
        local setup_script="${COMP_DIRS[$i]}/setup.bash"
        local name="${COMP_NAMES[$i]}"
        if [ -f "$setup_script" ]; then
            log info "Running post-install for $name..."
            echo "  $(gum style --foreground 212 "▶") Running post-install for $name..."
            if bash "$setup_script" 2>&1 | tee -a "$LOG_FILE"; then
                log info "Post-install for $name completed successfully"
                echo "  $(gum style --foreground 46 "✓") $name post-install done"
                succeeded+=("$name")
            else
                log error "Post-install failed for $name (check ~/.dotfiles-install.log)"
                echo "  $(gum style --foreground 196 "✗") $name post-install failed"
                failed+=("$name")
                if ! gum confirm "Continue with remaining components?"; then
                    break
                fi
            fi
        else
            echo "  $(gum style --foreground 242 "─") $name (no post-install script)"
            succeeded+=("$name")
        fi
    done

    # Create symlinks
    log info "Creating symlinks..."
    local only_slugs=""
    for i in "${indices[@]}"; do
        [ -n "$only_slugs" ] && only_slugs+=","
        only_slugs+="${COMP_SLUGS[$i]}"
    done
    python3 "$REPO_DIR/install.py" --only "$only_slugs"

    # Summary
    local elapsed=$(( SECONDS - start_time ))
    echo ""
    gum style --border double --padding "0 1" --border-foreground 46 \
        "Installation complete! (${elapsed}s)"
    echo ""
    for name in "${succeeded[@]}"; do
        echo "  $(gum style --foreground 46 "✓") $name"
    done
    for name in "${failed[@]}"; do
        echo "  $(gum style --foreground 196 "✗") $name (failed)"
    done
    echo ""
    log info "Install finished in ${elapsed}s"
    echo ""
    gum confirm "Back to menu" --affirmative="OK" --negative="" || true
}

# --- Run uninstall for selected indices ---
run_uninstall() {
    local indices=("$@")
    local all_apt=()
    local start_time=$SECONDS

    # Remove symlinks
    log info "Removing symlinks..."
    local only_slugs=""
    for i in "${indices[@]}"; do
        [ -n "$only_slugs" ] && only_slugs+=","
        only_slugs+="${COMP_SLUGS[$i]}"
    done
    python3 "$REPO_DIR/install.py" --unlink --only "$only_slugs"

    # Run uninstall scripts
    for i in "${indices[@]}"; do
        local uninstall_script="${COMP_DIRS[$i]}/uninstall.bash"
        local name="${COMP_NAMES[$i]}"
        if [ -f "$uninstall_script" ]; then
            log info "Running cleanup for $name..."
            bash "$uninstall_script" >> "$LOG_FILE" 2>&1 || true
        fi
    done

    # Optionally remove apt packages
    for i in "${indices[@]}"; do
        local deps_file="${COMP_DIRS[$i]}/deps.yaml"
        while IFS= read -r pkg; do
            [ -n "$pkg" ] && all_apt+=("$pkg")
        done < <(parse_yaml_list "$deps_file" "apt")
    done

    if [ ${#all_apt[@]} -gt 0 ]; then
        echo ""
        if gum confirm "Also remove apt packages? (${all_apt[*]})"; then
            log info "Removing apt packages..."
            sudo apt-get remove -y "${all_apt[@]}" || true
        fi
    fi

    local elapsed=$(( SECONDS - start_time ))
    echo ""
    gum style --border double --padding "0 1" --border-foreground 214 \
        "Uninstall complete! (${elapsed}s)"
    echo ""
    for i in "${indices[@]}"; do
        echo "  $(gum style --foreground 214 "−") ${COMP_NAMES[$i]}"
    done
    echo ""
    log info "Uninstall finished in ${elapsed}s"
    echo ""
    gum confirm "Back to menu" --affirmative="OK" --negative="" || true
}

# --- Run update (re-run setup + relink) for selected indices ---
run_update() {
    local indices=("$@")
    local start_time=$SECONDS
    local failed=() succeeded=()
    local all_apt=() all_pip=() all_ppa=()

    # Collect packages
    for i in "${indices[@]}"; do
        local deps_file="${COMP_DIRS[$i]}/deps.yaml"

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
    if [ ${#all_ppa[@]} -gt 0 ]; then
        log info "Adding PPAs..."
        for ppa in "${all_ppa[@]}"; do
            log info "Adding $ppa..."
            sudo add-apt-repository "$ppa" -y >> "$LOG_FILE" 2>&1
        done
    fi

    # Batch apt install
    if [ ${#all_apt[@]} -gt 0 ]; then
        log info "Updating apt packages..."
        local unique_apt=($(printf '%s\n' "${all_apt[@]}" | sort -u))
        echo "  Packages: ${unique_apt[*]}"
        gum spin --title "apt-get update" -- sudo apt-get update
        if ! sudo apt-get install -y "${unique_apt[@]}"; then
            log error "Some apt packages failed to install"
            if ! gum confirm "Continue anyway?"; then
                return 1
            fi
        fi
    fi

    # Batch pip install
    if [ ${#all_pip[@]} -gt 0 ]; then
        log info "Updating pip packages..."
        local unique_pip=($(printf '%s\n' "${all_pip[@]}" | sort -u))
        echo "  Packages: ${unique_pip[*]}"
        if ! pip install --user --break-system-packages "${unique_pip[@]}"; then
            log error "Some pip packages failed to install"
            if ! gum confirm "Continue anyway?"; then
                return 1
            fi
        fi
    fi

    # Run post-install scripts
    for i in "${indices[@]}"; do
        local setup_script="${COMP_DIRS[$i]}/setup.bash"
        local name="${COMP_NAMES[$i]}"
        if [ -f "$setup_script" ]; then
            log info "Re-running setup for $name..."
            echo "  $(gum style --foreground 212 "▶") Re-running setup for $name..."
            if bash "$setup_script" 2>&1 | tee -a "$LOG_FILE"; then
                log info "Setup for $name completed successfully"
                echo "  $(gum style --foreground 46 "✓") $name setup done"
                succeeded+=("$name")
            else
                log error "Setup failed for $name (check ~/.dotfiles-install.log)"
                echo "  $(gum style --foreground 196 "✗") $name setup failed"
                failed+=("$name")
                if ! gum confirm "Continue with remaining components?"; then
                    break
                fi
            fi
        else
            echo "  $(gum style --foreground 242 "─") $name (no setup script)"
            succeeded+=("$name")
        fi
    done

    # Re-create symlinks
    log info "Re-creating symlinks..."
    local only_slugs=""
    for i in "${indices[@]}"; do
        [ -n "$only_slugs" ] && only_slugs+=","
        only_slugs+="${COMP_SLUGS[$i]}"
    done
    python3 "$REPO_DIR/install.py" --unlink --only "$only_slugs"
    python3 "$REPO_DIR/install.py" --only "$only_slugs"

    local elapsed=$(( SECONDS - start_time ))
    echo ""
    gum style --border double --padding "0 1" --border-foreground 39 \
        "Update complete! (${elapsed}s)"
    echo ""
    for name in "${succeeded[@]}"; do
        echo "  $(gum style --foreground 46 "✓") $name"
    done
    for name in "${failed[@]}"; do
        echo "  $(gum style --foreground 196 "✗") $name (failed)"
    done
    echo ""
    log info "Update finished in ${elapsed}s"
    echo ""
    gum confirm "Back to menu" --affirmative="OK" --negative="" || true
}

# =====================================================================
# TUI Modes
# =====================================================================

mode_install() {
    local options=()
    local installed=()

    for i in "${!COMP_NAMES[@]}"; do
        local name="${COMP_NAMES[$i]}"
        local status="${COMP_STATUS[$i]}"
        if [ "$status" = "installed" ]; then
            installed+=("$name")
        else
            options+=("$name")
        fi
    done

    # Show already installed
    if [ ${#installed[@]} -gt 0 ]; then
        echo ""
        gum style --foreground 242 "Already installed:"
        for name in "${installed[@]}"; do
            echo "  $(gum style --foreground 242 "─") $name"
        done
    fi

    if [ ${#options[@]} -eq 0 ]; then
        echo ""
        log info "All components are already installed."
        echo ""
        gum confirm "Back to menu" --affirmative="OK" --negative="" || true
        return
    fi

    echo ""
    gum style --foreground 212 "Select components to install (space to toggle, enter to confirm):"
    echo ""

    local chosen
    chosen=$(gum choose --no-limit --selected="*" "${options[@]}") || return

    [ -z "$chosen" ] && { echo "No components selected."; return; }

    # Resolve dependencies
    chosen=$(resolve_dependencies "$chosen")

    echo ""
    gum style --foreground 212 "Will install:"
    echo "$chosen" | while IFS= read -r line; do
        [ -n "$line" ] && echo "  → $line"
    done

    echo ""
    if ! gum confirm "Proceed with installation?"; then
        echo "Cancelled."; return
    fi

    local idx_str
    idx_str=$(get_selected_indices "$chosen")
    read -ra selected_indices <<< "$idx_str"
    run_install "${selected_indices[@]}"
}

mode_uninstall() {
    # Show only installed components
    local options=()
    local installed_indices=()

    for i in "${!COMP_NAMES[@]}"; do
        if [ "${COMP_STATUS[$i]}" = "installed" ]; then
            options+=("${COMP_NAMES[$i]}")
            installed_indices+=("$i")
        fi
    done

    if [ ${#options[@]} -eq 0 ]; then
        log warn "No installed components to uninstall."
        return
    fi

    echo ""
    gum style --foreground 214 "Select components to uninstall (space to toggle, enter to confirm):"
    echo ""

    local chosen
    chosen=$(gum_choose_multi "${options[@]}") || return
    [ -z "$chosen" ] && { echo "No components selected."; return; }

    # Check if any still-installed component depends on a selected one
    local warnings=()
    for i in "${!COMP_NAMES[@]}"; do
        local name="${COMP_NAMES[$i]}"
        local slug="${COMP_SLUGS[$i]}"
        # Skip if this component is being uninstalled
        echo "$chosen" | grep -qF "$name" && continue
        # Skip if not installed
        [ "${COMP_STATUS[$i]}" = "installed" ] || continue
        # Check if it depends on something being uninstalled
        for req_slug in ${COMP_REQUIRES[$slug]}; do
            for j in "${!COMP_SLUGS[@]}"; do
                if [ "${COMP_SLUGS[$j]}" = "$req_slug" ]; then
                    if echo "$chosen" | grep -qF "${COMP_NAMES[$j]}"; then
                        warnings+=("$name depends on ${COMP_NAMES[$j]}")
                    fi
                fi
            done
        done
    done

    if [ ${#warnings[@]} -gt 0 ]; then
        echo ""
        gum style --foreground 214 "Warning - dependency conflicts:"
        for w in "${warnings[@]}"; do
            echo "  ! $w"
        done
        echo ""
        if ! gum confirm "Continue anyway?"; then
            echo "Cancelled."; return
        fi
    fi

    echo ""
    gum style --foreground 214 "Will uninstall:"
    echo "$chosen" | while IFS= read -r line; do
        [ -n "$line" ] && echo "  → $line"
    done

    echo ""
    if ! gum confirm "Proceed with uninstall?"; then
        echo "Cancelled."; return
    fi

    local idx_str
    idx_str=$(get_selected_indices "$chosen")
    read -ra selected_indices <<< "$idx_str"
    run_uninstall "${selected_indices[@]}"
}

mode_reinstall() {
    local options=()

    for i in "${!COMP_NAMES[@]}"; do
        options+=("${COMP_NAMES[$i]}")
    done

    echo ""
    gum style --foreground 39 "Select components to reinstall (space to toggle, enter to confirm):"
    echo ""

    local chosen
    chosen=$(gum_choose_multi "${options[@]}") || return
    [ -z "$chosen" ] && { echo "No components selected."; return; }

    # Resolve dependencies
    chosen=$(resolve_dependencies "$chosen")

    echo ""
    gum style --foreground 39 "Will reinstall:"
    echo "$chosen" | while IFS= read -r line; do
        [ -n "$line" ] && echo "  → $line"
    done

    echo ""
    if ! gum confirm "Proceed with reinstall?"; then
        echo "Cancelled."; return
    fi

    local idx_str
    idx_str=$(get_selected_indices "$chosen")
    read -ra selected_indices <<< "$idx_str"

    # Unlink first, then full install
    log info "Removing existing symlinks..."
    local only_slugs=""
    for i in "${selected_indices[@]}"; do
        [ -n "$only_slugs" ] && only_slugs+=","
        only_slugs+="${COMP_SLUGS[$i]}"
    done
    python3 "$REPO_DIR/install.py" --unlink --only "$only_slugs"

    run_install "${selected_indices[@]}"
}

mode_update() {
    # Show only installed components
    local options=()

    for i in "${!COMP_NAMES[@]}"; do
        if [ "${COMP_STATUS[$i]}" = "installed" ]; then
            options+=("${COMP_NAMES[$i]}")
        fi
    done

    if [ ${#options[@]} -eq 0 ]; then
        log warn "No installed components to update."
        return
    fi

    echo ""
    gum style --foreground 39 "Select components to update (space to toggle, enter to confirm):"
    echo ""

    local chosen
    chosen=$(gum_choose_multi "${options[@]}") || return
    [ -z "$chosen" ] && { echo "No components selected."; return; }

    echo ""
    gum style --foreground 39 "Will update (re-run setup + relink):"
    echo "$chosen" | while IFS= read -r line; do
        [ -n "$line" ] && echo "  → $line"
    done

    echo ""
    if ! gum confirm "Proceed with update?"; then
        echo "Cancelled."; return
    fi

    local idx_str
    idx_str=$(get_selected_indices "$chosen")
    read -ra selected_indices <<< "$idx_str"
    run_update "${selected_indices[@]}"
}

# =====================================================================
# Main menu
# =====================================================================

show_header() {
    clear
    gum style --border double --padding "0 2" --border-foreground 212 \
        "$(gum style --bold 'Dotfiles Manager')" \
        "github.com/miferco97/.dotfiles"
}

main() {
    log_init

    # Handle --help
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        echo "Usage: ./setup.bash"
        echo ""
        echo "Interactive TUI for managing dotfiles components."
        echo "All actions are available from the main menu."
        exit 0
    fi

    show_header
    discover_components
    show_status

    while true; do
        echo ""
        local action
        action=$(gum choose --header "What would you like to do?" \
            "Install components" \
            "Uninstall components" \
            "Reinstall components" \
            "Update components" \
            "Refresh status" \
            "Exit") || break

        case "$action" in
            "Install components")
                mode_install
                ;;
            "Uninstall components")
                mode_uninstall
                ;;
            "Reinstall components")
                mode_reinstall
                ;;
            "Update components")
                mode_update
                ;;
            "Refresh status")
                ;;
            "Exit")
                break
                ;;
        esac

        show_header
        discover_components
        show_status
    done

    echo "Bye!"
}

main "$@"
