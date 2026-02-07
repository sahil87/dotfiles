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

# OpenSpec completions (fpath set here, compinit called later in .zshrc)
OPENSPEC_COMPLETIONS_DIR="$HOME/.oh-my-zsh/custom/completions"
[[ -d "$OPENSPEC_COMPLETIONS_DIR" ]] && fpath=("$OPENSPEC_COMPLETIONS_DIR" $fpath)

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

# Path (first match wins) - OS_PATH_EXTRAS set by OS-specific config
path=($LIFETRACKER_DIR/bin $CODE_DIR/bin $OS_PATH_EXTRAS $path .)

# Devshell
[[ -f "$DEVSHELL_DIR/src/shell/dev.sh" ]] && source "$DEVSHELL_DIR/src/shell/dev.sh"
