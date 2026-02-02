#!/usr/bin/env bash
set -euo pipefail

# Pull SSH keys from remote server via Tailscale
# Prerequisite: Tailscale connected (run setup-tailscale.sh first)

KEY_SOURCE="sahils-mac-mini.bat-ordinal.ts.net"
SSH_KEYS=(
    "id_ed25519_sahil-weaver"
    "id_ed25519_sahil87"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

check_tailscale() {
    if ! command -v tailscale &> /dev/null; then
        error "Tailscale not installed. Run setup-tailscale.sh first."
    fi

    if ! tailscale status &> /dev/null; then
        error "Tailscale not connected. Run setup-tailscale.sh first."
    fi

    if ! ping -c 1 -W 5 "$KEY_SOURCE" &> /dev/null; then
        error "Cannot reach $KEY_SOURCE via Tailscale. Is the Mac Mini online?"
    fi
}

check_existing_keys() {
    local all_exist=true
    for key in "${SSH_KEYS[@]}"; do
        if [[ ! -f "$HOME/.ssh/$key" ]]; then
            all_exist=false
            break
        fi
    done

    if $all_exist; then
        warn "All SSH keys already exist in ~/.ssh/"
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || exit 0
    fi
}

pull_keys() {
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    info "Pulling SSH keys from $KEY_SOURCE..."

    for key in "${SSH_KEYS[@]}"; do
        info "  Fetching $key..."
        scp -o StrictHostKeyChecking=accept-new \
            "sahil@${KEY_SOURCE}:~/.ssh/${key}" \
            "$HOME/.ssh/${key}"
        scp "sahil@${KEY_SOURCE}:~/.ssh/${key}.pub" \
            "$HOME/.ssh/${key}.pub"
        chmod 600 "$HOME/.ssh/${key}"
        chmod 644 "$HOME/.ssh/${key}.pub"
    done

    info "SSH keys installed successfully!"
}

print_next_steps() {
    echo
    info "Next steps:"
    echo "  1. Test: ssh -T git@github.com"
    echo "  2. Test: ssh -T git@github.com-work"
}

main() {
    echo "=== Pull SSH Keys via Tailscale ==="
    echo
    check_tailscale
    check_existing_keys
    pull_keys
    print_next_steps
}

main "$@"
