#!/usr/bin/env bash
set -euo pipefail

# Install and connect Tailscale

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

install_tailscale() {
    if command -v tailscale &> /dev/null; then
        info "Tailscale already installed"
        return
    fi

    info "Installing Tailscale..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            error "Homebrew not installed. Install it first: https://brew.sh"
        fi
        brew install --cask tailscale
        info "Opening Tailscale app - please complete setup in the menu bar"
        open -a Tailscale
    elif [[ -f /etc/debian_version ]] || [[ -f /etc/ubuntu_version ]]; then
        curl -fsSL https://tailscale.com/install.sh | sh
    elif [[ -f /etc/fedora-release ]]; then
        sudo dnf install -y tailscale
        sudo systemctl enable --now tailscaled
    else
        error "Unsupported OS. Install Tailscale manually: https://tailscale.com/download"
    fi
}

ensure_connected() {
    info "Checking Tailscale connection..."

    # Wait for tailscale to be available (macOS app takes a moment)
    local retries=30
    while ! command -v tailscale &> /dev/null && (( retries > 0 )); do
        sleep 1
        ((retries--))
    done

    if ! tailscale status &> /dev/null; then
        info "Tailscale not connected. Running 'tailscale up'..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            warn "Please authenticate Tailscale via the menu bar app"
            exit 1
        else
            sudo tailscale up
        fi
    fi

    info "Tailscale connected"
    tailscale status
}

main() {
    echo "=== Tailscale Setup ==="
    echo
    install_tailscale
    ensure_connected
}

main "$@"
