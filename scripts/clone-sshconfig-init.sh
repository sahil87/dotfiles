#!/usr/bin/env bash
set -euo pipefail

# Starter ~/.ssh/config: just enough to clone the private lifetracker repo over SSH. The full config
# (ssh_linux / ssh_macos) is a stow package in lifetracker; stowing it replaces this file
# (stowhelper.sh --backup ssh_linux).
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

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    if [[ -f "$DEST" ]]; then
        warn "~/.ssh/config already exists."
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || exit 0
    fi

    cat > "$DEST" <<'EOF'
# Starter config from dotfiles/scripts/clone-sshconfig-init.sh. Replaced by the lifetracker stow package.
Host github.com
  User git
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519_github
  IdentityFile ~/.ssh/id_ed25519_sahil87

Host github.com-work
  HostName github.com
  User git
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519_sahil-noon
EOF
    chmod 600 "$DEST"
    info "Copied SSH config to $DEST"
}

main "$@"
