#!/usr/bin/env bash
set -euo pipefail

# Install and connect Tailscale
#   setup-tailscale.sh               join as your user: a TRUSTED device (laptop)
#   setup-tailscale.sh --trusted     join tagged tag:trusted   (trusted VMs on your own Proxmox hosts)
#   setup-tailscale.sh --dev-cloud   join tagged tag:dev-cloud (dev VMs in an org cloud project)
#   setup-tailscale.sh --edge        join tagged tag:edge      (service VMs)
# A tagged join still opens a login URL; sign in as yourself (a tag owner) and the device joins tagged, not as you.

TAG=""

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
        elif [[ -n "$TAG" ]]; then
            sudo tailscale up --advertise-tags="$TAG"
        else
            warn "Joining as your user makes this a TRUSTED device. For VMs, re-run with --trusted, --dev-cloud or --edge."
            read -p "Join as your user anyway? (y/N) " -n 1 -r
            echo
            [[ $REPLY =~ ^[Yy]$ ]] || exit 0
            sudo tailscale up
        fi
    elif [[ -n "$TAG" ]] && ! tailscale status --self --peers=false --json | grep -q "\"$TAG\""; then
        warn "Already connected, but not as $TAG. To re-join tagged:"
        echo "  sudo tailscale up --force-reauth --advertise-tags=$TAG"
        exit 1
    fi

    info "Tailscale connected"
    if [[ -n "$TAG" ]]; then
        info "If device approval is on, approve this machine in the admin console."
    fi
    tailscale status
}

main() {
    case "${1:-}" in
        --trusted) TAG="tag:trusted" ;;
        --dev-cloud) TAG="tag:dev-cloud" ;;
        --edge) TAG="tag:edge" ;;
        "") ;;
        *) error "Unknown option: $1 (usage: setup-tailscale.sh [--trusted | --dev-cloud | --edge])" ;;
    esac
    if [[ -n "$TAG" && "$OSTYPE" == "darwin"* ]]; then
        error "$1 is for Linux VMs. Macs are trusted and join through the Tailscale app (the mini is tagged tag:trusted in the admin console)"
    fi

    echo "=== Tailscale Setup${TAG:+ ($TAG)} ==="
    echo
    install_tailscale
    ensure_connected
}

main "$@"
