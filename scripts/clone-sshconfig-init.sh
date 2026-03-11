#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="$SCRIPT_DIR/../stow/linux/ssh/.ssh/config"
DEST="$HOME/.ssh/config"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

main() {
    echo "=== Copy SSH Config (starter) ==="
    echo

    if [[ ! -f "$CONFIG_SOURCE" ]]; then
        error "Source config not found: $CONFIG_SOURCE"
    fi

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    if [[ -f "$DEST" ]]; then
        warn "~/.ssh/config already exists."
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || exit 0
    fi

    cp "$CONFIG_SOURCE" "$DEST"
    chmod 600 "$DEST"
    info "Copied SSH config to $DEST"
}

main "$@"
