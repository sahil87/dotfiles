#!/bin/bash
# Simple helper script for dotfiles installation
# Usage: ./stowhelper.sh [package names...]
#   If no packages specified, shows usage and exits

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Auto-discover available packages (directories that aren't hidden)
AVAILABLE_PACKAGES=($(find . -maxdepth 1 -type d -not -name '.*' -not -name '.' -exec basename {} \; | sort))

show_usage() {
    echo "Dotfiles Installation (GNU Stow)"
    echo
    echo "Usage:"
    echo "  ./stowhelper.sh [package...]       Install specific packages"
    echo "  ./stowhelper.sh --all              Install all packages"
    echo "  ./stowhelper.sh --backup <pkg...>  Backup existing files then install"
    echo "  ./stowhelper.sh --adopt <pkg...>   Install and adopt existing files"
    echo "  ./stowhelper.sh --uninstall <pkg>  Remove package symlinks"
    echo "  ./stowhelper.sh --list             List available packages"
    echo
    echo "Examples:"
    echo "  ./stowhelper.sh git ssh            Install git and ssh configs"
    echo "  ./stowhelper.sh --all              Install everything"
    echo "  ./stowhelper.sh --backup ssh       Backup ~/.ssh/config then install"
    echo "  ./stowhelper.sh --adopt git ssh    Adopt existing ~/.gitconfig into stow"
    echo "  ./stowhelper.sh --uninstall git    Remove git symlinks"
    echo
    echo "Note: If you have existing dotfiles, use --backup to preserve them or"
    echo "      --adopt to move them into the stow directory."
    echo
    echo "Available packages:"
    printf "  - %s\n" "${AVAILABLE_PACKAGES[@]}"
}

check_stow() {
    if ! command -v stow &> /dev/null; then
        echo "Error: GNU Stow is not installed."
        echo
        echo "Install it with:"
        echo "  macOS:        brew install stow"
        echo "  Ubuntu/Debian: sudo apt install stow"
        echo "  Arch:         sudo pacman -S stow"
        exit 1
    fi
}

validate_packages() {
    local packages=("$@")
    local invalid=()

    for pkg in "${packages[@]}"; do
        if [[ ! " ${AVAILABLE_PACKAGES[*]} " =~ " ${pkg} " ]]; then
            invalid+=("$pkg")
        fi
    done

    if [ ${#invalid[@]} -gt 0 ]; then
        echo "Error: Unknown package(s): ${invalid[*]}"
        echo
        echo "Available packages:"
        printf "  - %s\n" "${AVAILABLE_PACKAGES[@]}"
        exit 1
    fi
}

install_packages() {
    local adopt_mode=false
    if [ "$1" = "--with-adopt" ]; then
        adopt_mode=true
        shift
    fi

    local packages=("$@")
    validate_packages "${packages[@]}"

    echo "Installing packages: ${packages[*]}"

    if [ "$adopt_mode" = true ]; then
        echo "⚠️  Using --adopt mode: existing files will be moved into stow directory"
        stow -t ~ --adopt -v "${packages[@]}"
    else
        stow -t ~ -v "${packages[@]}"
    fi

    echo
    echo "✓ Installation complete!"
}

uninstall_packages() {
    local packages=("$@")
    validate_packages "${packages[@]}"

    echo "Removing packages: ${packages[*]}"
    stow -t ~ -D -v "${packages[@]}"
    echo
    echo "✓ Uninstall complete!"
}

backup_and_install_packages() {
    local packages=("$@")
    validate_packages "${packages[@]}"

    echo "Checking for conflicts with packages: ${packages[*]}"

    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local backed_up=0

    # Directly check which files would conflict
    for pkg in "${packages[@]}"; do
        if [ ! -d "$pkg" ]; then
            echo "Warning: Package directory '$pkg' not found, skipping"
            continue
        fi

        # Find all files in the package directory
        while IFS= read -r src_file; do
            # Get the relative path (remove package prefix and leading ./)
            local rel_path="${src_file#$pkg/}"
            local target="$HOME/$rel_path"

            # Only backup if it's a regular file (not a symlink, which might be stow-managed)
            if [ -f "$target" ] && [ ! -L "$target" ]; then
                if [ $backed_up -eq 0 ]; then
                    echo
                    echo "⚠️  Found conflicting files. Backing them up with timestamp: $timestamp"
                    echo
                fi
                local backup_file="${target}.backup-${timestamp}"
                echo "  Backing up: ~/$rel_path → ~/${rel_path}.backup-${timestamp}"
                mv "$target" "$backup_file"
                backed_up=$((backed_up + 1))
            fi
        done < <(find "$pkg" -type f)
    done

    if [ $backed_up -gt 0 ]; then
        echo
    fi

    # Now install the packages
    echo "Installing packages: ${packages[*]}"
    stow -t ~ -v "${packages[@]}"

    echo
    echo "✓ Installation complete!"
    if [ $backed_up -gt 0 ]; then
        echo "  Backed up $backed_up file(s) with suffix: .backup-${timestamp}"
    fi
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_usage
    exit 0
fi

check_stow

case "$1" in
    --help|-h)
        show_usage
        ;;
    --list|-l)
        echo "Available packages:"
        printf "  - %s\n" "${AVAILABLE_PACKAGES[@]}"
        ;;
    --all|-a)
        install_packages "${AVAILABLE_PACKAGES[@]}"
        ;;
    --adopt)
        shift
        if [ $# -eq 0 ]; then
            echo "Error: --adopt requires package names"
            exit 1
        fi
        install_packages --with-adopt "$@"
        ;;
    --backup|-b)
        shift
        if [ $# -eq 0 ]; then
            echo "Error: --backup requires package names"
            exit 1
        fi
        backup_and_install_packages "$@"
        ;;
    --uninstall|-u)
        shift
        if [ $# -eq 0 ]; then
            echo "Error: --uninstall requires package names"
            exit 1
        fi
        uninstall_packages "$@"
        ;;
    *)
        install_packages "$@"
        ;;
esac
