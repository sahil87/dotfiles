#!/bin/zsh

# Linux-specific configuration (sourced by .zshrc_os.sh)

# OS-specific tool paths (used by common config)
NVM_SOURCE="$HOME/.nvm"
export PNPM_HOME="$HOME/.local/share/pnpm"
OS_PATH_EXTRAS=($HOME/.local/bin)

# linuxbrew
[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
