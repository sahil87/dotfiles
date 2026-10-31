#!/usr/bin/env bash
set -euo pipefail

# Let trusted machines (laptop, Mac mini) SSH into THIS machine with the ss key.
# Run it on the new machine, as the user you'll SSH in as. It needs no network or Tailscale:
# the public key is embedded below. Standalone, so it also works without cloning:
#   curl -fsSL https://raw.githubusercontent.com/sahil87/dotfiles/main/scripts/authorize-ss-key.sh | bash
# Proxmox VMs don't need this: cloud-init installs the same key.

SS_PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMILAUxNl94nRXJ7osEVArZ8801FpUOc43NWkQibL3F sahil-systems@2026-03-04"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

main() {
    echo "=== Authorize ss key ==="
    echo

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    touch "$HOME/.ssh/authorized_keys"
    chmod 600 "$HOME/.ssh/authorized_keys"

    # Match on the key itself, not the comment
    local key_body
    key_body=$(echo "$SS_PUBKEY" | awk '{print $2}')
    [[ -n "$key_body" ]] || error "SS_PUBKEY is empty"

    if grep -qF "$key_body" "$HOME/.ssh/authorized_keys"; then
        warn "ss key already in ~/.ssh/authorized_keys, skipping."
    else
        echo "$SS_PUBKEY" >> "$HOME/.ssh/authorized_keys"
        info "Added ss key to ~/.ssh/authorized_keys"
    fi

    echo
    info "From a trusted machine: ssh $(whoami)@<this host>"
}

main "$@"
