#!/bin/zsh

# macOS-specific configuration (sourced by .zshrc_os.sh)
#
# Setup instructions:
# Install zap: zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

export ICLOUD='/Users/sahil/Library/Mobile Documents/com~apple~CloudDocs'

# OS-specific tool paths (used by common config)
NVM_SOURCE="/opt/homebrew/opt/nvm"
export PNPM_HOME="/Users/sahil/Library/pnpm"
OS_PATH_EXTRAS=(/opt/homebrew/bin)

# Ollama runs on the Mac Mini, bound to its Tailscale IP (lifetracker: guides/macmini/llm-serving.md).
# MagicDNS resolves this name on the Mini itself too, so one static value works on every Mac —
# no `tailscale ip` subprocess on shell start.
export OLLAMA_HOST=sahils-mac-mini.bat-ordinal.ts.net:11434

# TODO: Install zap and add theme here
# Example: plug "zap-zsh/supercharge"
# Example: plug "zap-zsh/zap-prompt"

# plug "rkh/zsh-jj"
