#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Only the ss key is shared between trusted machines. GitHub keys are per machine and per account
# (id_ed25519_sahil87, id_ed25519_sahil-noon): generated on each machine, never copied.
SSH_KEYS=(
    "id_ed25519_ss"
)

source "$SCRIPT_DIR/_clone-sshkey.sh"
clone_sshkeys
