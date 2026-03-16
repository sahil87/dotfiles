#!/usr/bin/env bash
set -euo pipefail

# Reset byobu and tmux to a clean state.
# Fixes: green status bar, broken F-keys, byobu looking like plain tmux.
#
# Root cause: if a plain tmux server is already running, byobu attaches to it
# without its BYOBU_* env vars, so keybindings and status bar never load.
#
# Prerequisites:
#   brew install gnu-sed   # byobu's sed -i calls break with macOS BSD sed

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}==> Killing tmux server (all sessions will be lost)${NC}"
tmux kill-server 2>/dev/null && echo "    tmux server killed" || echo "    no tmux server running"

echo -e "${YELLOW}==> Removing byobu config directories${NC}"
rm -rf ~/.config/byobu ~/.byobu
echo "    removed ~/.config/byobu and ~/.byobu"

echo -e "${YELLOW}==> Checking for gnu-sed (required by byobu on macOS)${NC}"
if command -v gsed >/dev/null 2>&1; then
    echo -e "    ${GREEN}gsed found${NC}"
else
    echo -e "    ${RED}gsed not found — install with: brew install gnu-sed${NC}"
fi

echo
echo -e "${GREEN}Reset complete. Run 'byobu-enable' if needed, then start a fresh session with: byobu${NC}"
