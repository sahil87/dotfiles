#!/bin/zsh

# Common OS configuration (sourced by OS-specific files)

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
