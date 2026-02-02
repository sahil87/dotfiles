#!/bin/zsh

# macOS-specific configuration
#
# Setup instructions:
# Install zap: zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

export CODE_DIR=`realpath $HOME/code`
export SAHIL87_DIR=`realpath $HOME/code/sahil87`
export WEAVER_DIR=`realpath $HOME/code/weaver`

export ICLOUD='/Users/sahil/Library/Mobile Documents/com~apple~CloudDocs'

# Source common OS configuration
source "${0:a:h}/.zshrc_os.sh"

# kubectl completions auto-load via fpath (/opt/homebrew/share/zsh/site-functions)
# ssh-agent: manage manually if needed

# TODO: Install zap and add theme here
# Example: plug "zap-zsh/supercharge"
# Example: plug "zap-zsh/zap-prompt"

# NVM (homebrew)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# pnpm (macOS path)
export PNPM_HOME="/Users/sahil/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# plug "rkh/zsh-jj"

# Path (first match wins)
path=($LIFETRACKER_DIR/bin $CODE_DIR/bin /opt/homebrew/bin $path .)

source "$DEVSHELL_DIR/src/shell/dev.sh"
