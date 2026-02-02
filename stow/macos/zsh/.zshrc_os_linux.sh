#!/bin/zsh

# Linux-specific configuration (Ubuntu)

export CODE_DIR="$HOME/code"
export SAHIL87_DIR="$HOME/code/sahil87"
export WEAVER_DIR="$HOME/code/weaver"

# Source common OS configuration
source "${0:a:h}/.zshrc_os.sh"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pnpm (Linux path)
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Path (first match wins)
path=($LIFETRACKER_DIR/bin $CODE_DIR/bin $HOME/.local/bin $path .)

# Source devshell if it exists
[[ -f "$DEVSHELL_DIR/src/shell/dev.sh" ]] && source "$DEVSHELL_DIR/src/shell/dev.sh"
