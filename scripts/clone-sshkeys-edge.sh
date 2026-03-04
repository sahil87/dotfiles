#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SSH_KEYS=(
    "id_ed25519_sahil-weaver"
    "id_ed25519_sahil87"
)

source "$SCRIPT_DIR/_clone-sshkey.sh"
clone_sshkeys
