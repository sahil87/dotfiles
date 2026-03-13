#!/bin/zsh

# Common OS configuration
# Import tree: .zshrc → _os → (_os_linux | _os_macos)

# Directory exports
export CODE_DIR="$HOME/code"
export SAHIL87_DIR="$HOME/code/sahil87"
export WEAVER_DIR="$HOME/code/weaver"

# Source OS-specific config (sets NVM_SOURCE, PNPM_HOME, OS_PATH_EXTRAS)
case "$(uname)" in
  Darwin) source "${0:a:h}/.zshrc_os_macos.sh" ;;
  Linux)  source "${0:a:h}/.zshrc_os_linux.sh" ;;
esac

# Directory aliases
alias weaver="cd $WEAVER_DIR"
alias bb="cd $BOOTSTRAP_DIR"
alias pp="cd $PP_DIR"
alias lt="cd $LIFETRACKER_DIR"

# Docker completions (cached for performance)
if command -v docker &> /dev/null; then
  DOCKER_COMPLETION_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/docker-completion.zsh"
  if [[ ! -f "$DOCKER_COMPLETION_CACHE" ]] || [[ $(find "$DOCKER_COMPLETION_CACHE" -mtime +7 2>/dev/null) ]]; then
    docker completion zsh > "$DOCKER_COMPLETION_CACHE" 2>/dev/null
  fi
  [[ -f "$DOCKER_COMPLETION_CACHE" ]] && source "$DOCKER_COMPLETION_CACHE"
fi

# Graphite completions (cached for performance)
if command -v gt &> /dev/null; then
  GT_COMPLETION_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/gt-completion.zsh"
  if [[ ! -f "$GT_COMPLETION_CACHE" ]] || [[ $(find "$GT_COMPLETION_CACHE" -mtime +7 2>/dev/null) ]]; then
    gt completion zsh > "$GT_COMPLETION_CACHE" 2>/dev/null
  fi
  [[ -f "$GT_COMPLETION_CACHE" ]] && source "$GT_COMPLETION_CACHE"
fi

# fpath completions (compinit called later in .zshrc)
# Tools that output #compdef functions (e.g. just) must go via fpath, not source
COMPLETIONS_DIR="$HOME/.oh-my-zsh/custom/completions"
mkdir -p "$COMPLETIONS_DIR"

# Just completions (cached, regenerated weekly)
if command -v just &> /dev/null; then
  if [[ ! -f "$COMPLETIONS_DIR/_just" ]] || [[ $(find "$COMPLETIONS_DIR/_just" -mtime +7 2>/dev/null) ]]; then
    just --completions zsh > "$COMPLETIONS_DIR/_just" 2>/dev/null
  fi
fi

fpath=("$COMPLETIONS_DIR" $fpath)

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "${NVM_SOURCE:-$NVM_DIR}/nvm.sh" ] && \. "${NVM_SOURCE:-$NVM_DIR}/nvm.sh"
[ -s "${NVM_SOURCE:-$NVM_DIR}/bash_completion" ] && \. "${NVM_SOURCE:-$NVM_DIR}/bash_completion"
[ -s "${NVM_SOURCE:-$NVM_DIR}/etc/bash_completion.d/nvm" ] && \. "${NVM_SOURCE:-$NVM_DIR}/etc/bash_completion.d/nvm"

# pnpm
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Go
[[ -d "$HOME/go/bin" ]] && GO_BIN="$HOME/go/bin"

# Path (first match wins) - OS_PATH_EXTRAS set by OS-specific config
path=($GO_BIN $HOME/.cargo/bin $LIFETRACKER_DIR/bin $CODE_DIR/bin $OS_PATH_EXTRAS $path .)

