#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEYS=() # not pulling any keys, just using the lib utilities
source "$SCRIPT_DIR/_clone-sshkey.sh"

SS_KEY="id_ed25519_ss"

main() {
    echo "=== Authorize SS Key via Tailscale ==="
    echo
    check_tailscale

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    touch "$HOME/.ssh/authorized_keys"
    chmod 600 "$HOME/.ssh/authorized_keys"

    info "Fetching $SS_KEY.pub from $KEY_SOURCE..."
    pub_key=$(ssh -o StrictHostKeyChecking=accept-new "sahil@${KEY_SOURCE}" "cat ~/.ssh/${SS_KEY}.pub")

    if grep -qF "$pub_key" "$HOME/.ssh/authorized_keys" 2>/dev/null; then
        warn "Key already in authorized_keys, skipping."
    else
        echo "$pub_key" >> "$HOME/.ssh/authorized_keys"
        info "Added $SS_KEY.pub to ~/.ssh/authorized_keys"
    fi
}

main "$@"
