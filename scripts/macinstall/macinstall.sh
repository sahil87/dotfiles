#!/bin/bash

# Mac Software Installation Script
# Reads categories from Brewfile and installs with interactive prompts
# Brewfile is the single source of truth - no duplication!

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

# Validate Brewfile exists
if [[ ! -f "$BREWFILE" ]]; then
    echo "Error: Brewfile not found at $BREWFILE"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
}

print_category() {
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│ ${YELLOW}$1${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
}

print_item() {
    echo -e "  ${GREEN}•${NC} $1"
}

print_installed() {
    echo -e "  ${DIM}✓ $1 (installed)${NC}"
}

print_missing() {
    echo -e "  ${YELLOW}○${NC} $1 ${RED}(missing)${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Sudo keep-alive: ask once, then refresh in background
setup_sudo() {
    print_info "Requesting sudo access (will be cached for the session)..."
    sudo -v

    # Keep sudo alive in background
    while true; do
        sudo -n true
        sleep 50
        kill -0 "$$" 2>/dev/null || exit
    done &
    SUDO_KEEPALIVE_PID=$!
}

cleanup() {
    # Kill the sudo keepalive process
    if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi
}

trap cleanup EXIT

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed!"
        echo "Install it with:"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    print_success "Homebrew is installed"
}

# Prompt user for category installation
prompt_install() {
    local category="$1"
    local default="${2:-y}"

    # Dry run mode - never install
    if [[ "$DRY_RUN" == "true" ]]; then
        return 1
    fi

    # Auto-yes mode - always install
    if [[ "$AUTO_YES" == "true" ]]; then
        return 0
    fi

    echo ""
    if [[ "$default" == "y" ]]; then
        read -p "Install missing packages? [Y/n/q] " -n 1 -r response </dev/tty
    else
        read -p "Install missing packages? [y/N/q] " -n 1 -r response </dev/tty
    fi
    echo ""

    response=${response:-$default}

    if [[ "$response" =~ ^[Qq]$ ]]; then
        print_info "Quitting installation..."
        exit 0
    fi

    [[ "$response" =~ ^[Yy]$ ]]
}

# Check if brew formula is installed
is_brew_installed() {
    local formula="$1"
    brew list --formula "$formula" &>/dev/null
}

# Get the app name for a cask (e.g., "visual-studio-code" -> "Visual Studio Code.app")
get_cask_app_name() {
    local cask="$1"
    brew info --cask "$cask" --json=v2 2>/dev/null | \
        jq -r '.casks[0].artifacts[] | .app? // empty | .[0]' 2>/dev/null | \
        head -1
}

# Check if a cask is already installed (via brew or manually)
is_cask_installed() {
    local cask="$1"

    # Check if brew knows about it
    if brew list --cask "$cask" &>/dev/null; then
        return 0
    fi

    # Check if the app exists in /Applications or ~/Applications
    local app_name
    app_name=$(get_cask_app_name "$cask")
    if [[ -n "$app_name" ]]; then
        if [[ -d "/Applications/$app_name" ]] || [[ -d "$HOME/Applications/$app_name" ]]; then
            return 0
        fi
    fi

    return 1
}

# Check if mas app is installed
is_mas_installed() {
    local id="$1"
    mas list 2>/dev/null | grep -qE "^\s*$id\b"
}

# =============================================================================
# Brewfile Parsing Functions
# =============================================================================

# Get list of all category names from Brewfile
get_categories() {
    grep -E '^# === CATEGORY:' "$BREWFILE" | \
        awk -F'|' '{sub(/^# === CATEGORY: */, "", $1); sub(/ *$/, "", $1); print $1}'
}

# Get category metadata: type (brew/cask/mas)
get_category_type() {
    local category="$1"
    grep -E "^# === CATEGORY: ${category} \|" "$BREWFILE" | \
        awk -F'|' '{gsub(/^ +| +$/, "", $2); print $2}'
}

# Get category metadata: default (y/n)
get_category_default() {
    local category="$1"
    grep -E "^# === CATEGORY: ${category} \|" "$BREWFILE" | \
        awk -F'|' '{gsub(/^ +| +$/, "", $3); print $3}'
}

# Get category metadata: description
get_category_description() {
    local category="$1"
    grep -E "^# === CATEGORY: ${category} \|" "$BREWFILE" | \
        awk -F'|' '{gsub(/^ +| +$| *===$/, "", $4); print $4}'
}

# Get packages for a category (brew/cask)
get_category_packages() {
    local category="$1"
    local pkg_type="$2"  # brew or cask

    # Extract lines between category start and end
    sed -n "/^# === CATEGORY: ${category} |/,/^# === END CATEGORY ===/p" "$BREWFILE" | \
        grep "^${pkg_type} " | \
        sed "s/${pkg_type} \"\([^\"]*\)\".*/\1/"
}

# Get mas apps for a category (returns "Name:ID" format)
get_category_mas_apps() {
    local category="$1"

    sed -n "/^# === CATEGORY: ${category} |/,/^# === END CATEGORY ===/p" "$BREWFILE" | \
        grep '^mas ' | \
        sed 's/mas "\([^"]*\)", id: *\([0-9]*\).*/\1:\2/'
}

# =============================================================================
# Installation Processing Functions
# =============================================================================

# Process a category of brew formulas
process_brews() {
    local category="$1"
    local description="$2"
    local default="$3"
    shift 3
    local formulas=("$@")

    local missing=()
    local installed=()

    # Check what's installed vs missing
    for formula in "${formulas[@]}"; do
        if is_brew_installed "$formula"; then
            installed+=("$formula")
        else
            missing+=("$formula")
        fi
    done

    print_category "$category"
    [[ -n "$description" ]] && echo "$description"

    # Show status
    for item in "${installed[@]}"; do
        print_installed "$item"
    done
    for item in "${missing[@]}"; do
        print_missing "$item"
    done

    # If nothing missing, skip
    if [[ ${#missing[@]} -eq 0 ]]; then
        print_success "All $category already installed"
        return 0
    fi

    # Ask user if they want to install
    if prompt_install "$category" "$default"; then
        local failed=0
        for formula in "${missing[@]}"; do
            print_item "Installing $formula..."
            if ! brew install "$formula"; then
                print_error "Failed to install $formula"
                ((failed++))
            fi
        done
        if [[ $failed -eq 0 ]]; then
            print_success "$category installation complete"
        else
            print_error "$category: $failed package(s) failed to install"
        fi
    fi

    return 0
}

# Process a category of casks
process_casks() {
    local category="$1"
    local description="$2"
    local default="$3"
    shift 3
    local casks=("$@")

    local missing=()
    local installed=()

    # Check what's installed vs missing
    for cask in "${casks[@]}"; do
        if is_cask_installed "$cask"; then
            installed+=("$cask")
        else
            missing+=("$cask")
        fi
    done

    print_category "$category"
    [[ -n "$description" ]] && echo "$description"

    # Show status
    for item in "${installed[@]}"; do
        print_installed "$item"
    done
    for item in "${missing[@]}"; do
        print_missing "$item"
    done

    # If nothing missing, skip
    if [[ ${#missing[@]} -eq 0 ]]; then
        print_success "All $category already installed"
        return 0
    fi

    # Ask user if they want to install
    if prompt_install "$category" "$default"; then
        local failed=0
        for cask in "${missing[@]}"; do
            print_item "Installing $cask..."
            if ! brew install --cask "$cask"; then
                print_error "Failed to install $cask"
                ((failed++))
            fi
        done
        if [[ $failed -eq 0 ]]; then
            print_success "$category installation complete"
        else
            print_error "$category: $failed package(s) failed to install"
        fi
    fi

    return 0
}

# Process Mac App Store apps
process_mas() {
    local category="$1"
    local description="$2"
    local default="$3"
    shift 3
    local apps=("$@")

    local missing=()
    local missing_names=()
    local installed=()

    # Check what's installed vs missing
    for app in "${apps[@]}"; do
        local name="${app%%:*}"
        local id="${app##*:}"
        if is_mas_installed "$id"; then
            installed+=("$name")
        else
            missing+=("$app")
            missing_names+=("$name")
        fi
    done

    print_category "$category"
    [[ -n "$description" ]] && echo "$description"

    # Show status
    for item in "${installed[@]}"; do
        print_installed "$item"
    done
    for item in "${missing_names[@]}"; do
        print_missing "$item"
    done

    # If nothing missing, skip
    if [[ ${#missing[@]} -eq 0 ]]; then
        print_success "All $category already installed"
        return 0
    fi

    # Ask user if they want to install
    if prompt_install "$category" "$default"; then
        local failed=0
        for app in "${missing[@]}"; do
            local name="${app%%:*}"
            local id="${app##*:}"
            print_item "Installing $name (ID: $id)..."
            if ! mas install "$id"; then
                print_error "Failed to install $name"
                ((failed++))
            fi
        done
        if [[ $failed -eq 0 ]]; then
            print_success "$category installation complete"
        else
            print_error "$category: $failed package(s) failed to install"
        fi
    fi

    return 0
}

# Process a single category from Brewfile
process_category() {
    local category="$1"
    local pkg_type description default

    pkg_type=$(get_category_type "$category")
    description=$(get_category_description "$category")
    default=$(get_category_default "$category")

    case "$pkg_type" in
        brew)
            local packages=()
            while IFS= read -r pkg; do
                [[ -n "$pkg" ]] && packages+=("$pkg")
            done < <(get_category_packages "$category" "brew")

            if [[ ${#packages[@]} -gt 0 ]]; then
                process_brews "$category" "$description" "$default" "${packages[@]}"
            fi
            ;;
        cask)
            local packages=()
            while IFS= read -r pkg; do
                [[ -n "$pkg" ]] && packages+=("$pkg")
            done < <(get_category_packages "$category" "cask")

            if [[ ${#packages[@]} -gt 0 ]]; then
                process_casks "$category" "$description" "$default" "${packages[@]}"
            fi
            ;;
        mas)
            local apps=()
            while IFS= read -r app; do
                [[ -n "$app" ]] && apps+=("$app")
            done < <(get_category_mas_apps "$category")

            if [[ ${#apps[@]} -gt 0 ]]; then
                process_mas "$category" "$description" "$default" "${apps[@]}"
            fi
            ;;
        *)
            print_error "Unknown package type '$pkg_type' for category '$category'"
            ;;
    esac
}

# Extract and add required taps from Brewfile
setup_taps() {
    print_category "Adding required taps"

    # Extract tap formulas (format: tap/repo/formula)
    local taps=()
    while IFS= read -r formula; do
        if [[ "$formula" == */* ]]; then
            local tap="${formula%/*}"  # Extract "tap/repo" from "tap/repo/formula"
            taps+=("$tap")
        fi
    done < <(grep '^brew ' "$BREWFILE" | sed 's/brew "\([^"]*\)".*/\1/')

    # Remove duplicates and add taps
    local unique_taps=($(printf '%s\n' "${taps[@]}" | sort -u))
    for tap in "${unique_taps[@]}"; do
        brew tap "$tap" 2>/dev/null || true
    done

    print_success "Taps configured"
}

# Update Brewfile from currently installed packages
update_brewfile() {
    print_header "Updating Brewfile"

    local backup="$BREWFILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$BREWFILE" "$backup"
    print_success "Backed up current Brewfile to $backup"

    echo "Choose update method:"
    echo "  1) Dump all installed packages (overwrites current organization)"
    echo "  2) Show diff of what's installed vs Brewfile (recommended)"
    echo "  3) Cancel"
    read -p "Choice [1/2/3]: " -n 1 -r choice
    echo ""

    case $choice in
        1)
            brew bundle dump --file="$BREWFILE" --force
            print_success "Brewfile updated with all installed packages"
            print_info "Note: Category markers will be lost - reorganize manually"
            ;;
        2)
            echo ""
            print_category "Packages installed but NOT in Brewfile:"
            brew bundle cleanup --file="$BREWFILE" 2>/dev/null || true
            echo ""
            print_category "Packages in Brewfile but NOT installed:"
            brew bundle check --file="$BREWFILE" --verbose 2>/dev/null || true
            echo ""
            print_info "Edit $BREWFILE manually to add/remove packages"
            ;;
        3)
            print_info "Cancelled"
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Show current Brewfile contents
show_brewfile() {
    print_header "Current Brewfile Contents"
    cat "$BREWFILE"
}

# Main installation routine
run_installation() {
    print_header "Mac Software Installation"
    echo "This script reads categories from Brewfile, shows what's missing,"
    echo "and installs packages you choose."

    check_homebrew

    # Ask for installation mode if not already set via -y flag
    if [[ "$AUTO_YES" != "true" ]]; then
        echo ""
        echo "How would you like to proceed?"
        echo "  1) Interactive - prompt for each category with missing packages"
        echo "  2) Install all - automatically install all missing packages"
        echo "  3) Dry run - just show what's missing, don't install anything"
        read -p "Choice [1/2/3]: " -n 1 -r mode_choice
        echo ""

        case $mode_choice in
            2)
                AUTO_YES="true"
                print_info "Auto-install mode: will install all missing packages"
                ;;
            3)
                DRY_RUN="true"
                print_info "Dry run mode: will only show what's missing"
                ;;
            *)
                print_info "Interactive mode: will prompt for each category"
                echo "Press 'y' to install, 'n' to skip, 'q' to quit."
                ;;
        esac
    fi

    # Setup sudo keep-alive (skip for dry run)
    if [[ "$DRY_RUN" != "true" ]]; then
        setup_sudo
    fi

    # Setup required taps
    setup_taps

    # Process all categories from Brewfile
    while IFS= read -r category; do
        [[ -n "$category" ]] && process_category "$category"
    done < <(get_categories)

    print_header "Installation Complete!"
    echo "Run 'brew cleanup' to remove old versions and free up space."
}

# Show help
show_help() {
    echo "Mac Software Installation Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install     Run installation (prompts for mode at start)"
    echo "  install -y  Install all missing packages without prompts"
    echo "  update      Update/manage Brewfile"
    echo "  show        Show current Brewfile contents"
    echo "  check       Check what's installed vs Brewfile"
    echo "  help        Show this help message"
    echo ""
    echo "Installation modes (selected at start):"
    echo "  1) Interactive - prompt for each category with missing packages"
    echo "  2) Install all - automatically install all missing packages"
    echo "  3) Dry run - just show what's missing, don't install anything"
    echo ""
    echo "Brewfile format:"
    echo "  Categories are marked with: # === CATEGORY: Name | type | default | description ==="
    echo "  Types: brew, cask, mas"
    echo "  Default: y (install by default) or n (skip by default)"
    echo ""
    echo "Examples:"
    echo "  $0              # Run with mode selection"
    echo "  $0 install -y   # Install everything (skip mode selection)"
    echo "  $0 update       # Update Brewfile"
}

# Check installed vs Brewfile
check_status() {
    print_header "Installation Status"

    echo ""
    print_category "Missing from system (in Brewfile but not installed):"
    brew bundle check --file="$BREWFILE" --verbose 2>/dev/null || true

    echo ""
    print_category "Not in Brewfile (installed but not tracked):"
    brew bundle cleanup --file="$BREWFILE" 2>/dev/null || true
}

# Main entry point
main() {
    case "${1:-help}" in
        install)
            if [[ "${2:-}" == "-y" ]]; then
                AUTO_YES="true"
            fi
            run_installation
            ;;
        update)
            update_brewfile
            ;;
        show)
            show_brewfile
            ;;
        check)
            check_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
