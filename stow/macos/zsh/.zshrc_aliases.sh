#!/bin/zsh
alias cd..='cd ../' # Go back 1 directory level (for fast typers)
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .3='cd ../../../'    # Go back 3 directory levels
alias .4='cd ../../../../' # Go back 4 directory levels
alias .5='cd ../../../../../'   # Go back 5 directory levels
alias .6='cd ../../../../../../'  # Go back 6 directory levels

# Make a directory and cd into it
take() { mkdir -p "$1" && cd "$1" }

#Ls improvements
alias ls='ls --color=auto'
alias ll='ls -Fhl'
alias lla='ls -Fahl'
alias sl="ls"
alias l="ls"

# Make these commands ask before clobbering a file. Use -f to override.
alias rm="nocorrect rm -i" #nocorrect doesn't work in bash
#alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

#Git aliases
# alias gs='git status' # Use gst
# alias gcm='git commit -m' # Use gsam
alias gloga='git log --oneline --decorate --graph --all'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias gl='gloga'
alias gll='glola'
alias p='git pull'
alias gp='git push'
alias gaa='git add --all'
alias gr="git remote"
alias gcm='git commit -m'
alias gco='git checkout'
alias gb='git branch'
alias gst='git status'
alias gcam='git commit -am'

alias gk='gitk --all&'
alias gx='gitx --all'
alias c='cd ~/code/'

alias p8='ping 8.8.8.8'
alias install='sudo apt-get install'
alias remove='sudo apt-get remove'
alias update='sudo apt-get update'
alias upgrade='sudo apt-get update && sudo apt-get upgrade'
alias b="byobu"
alias d="docker"

#Command shortcuts
alias kc='kubectl'
alias mux='tmuxinator'
alias gpg2='gpg'

#Claude
alias clauded='claude --allow-dangerously-skip-permissions'

# Save a checkpoint (snapshot current state, keep working)
save() {
  git add -A
  git stash push -m "checkpoint-$(date +%Y%m%d-%H%M%S)"
  git stash apply --quiet
  echo "✓ Saved checkpoint"
}

# Go back to a checkpoint (default: most recent)
# Usage: back or back 2 (for stash@{2})
back() {
  git checkout .
  git clean -fd
  git stash apply "stash@{${1:-0}}" --quiet
  echo "✓ Restored checkpoint ${1:-0}"
}

# Preview what's in a checkpoint without restoring
peek() {
  git stash show -p "stash@{${1:-0}}"
}

# List all checkpoints
alias saves='git stash list'
# Fix terminal state (after binary abrupt ssh connectino with mouse on messes it up)
alias fix='stty sane; printf "\e[?1000l\e[?1002l\e[?1003l\e[?1006l"; clear'

# AI Agent Usage Tracking {{{
# Claude Code
alias ccu='npx ccusage@latest'
alias ccud='npx ccusage@latest daily'
alias ccum='npx ccusage@latest monthly'
alias ccus='npx ccusage@latest session'
alias ccub='npx ccusage@latest blocks'

# OpenAI Codex CLI
alias codexu='npx @ccusage/codex@latest'
alias codexud='npx @ccusage/codex@latest daily'
alias codexum='npx @ccusage/codex@latest monthly'

# OpenCode
alias ocu='npx @ccusage/opencode@latest'
alias ocud='npx @ccusage/opencode@latest daily'
alias ocum='npx @ccusage/opencode@latest monthly'

# All agents daily summary (quick check)
alias aiu='echo "=== Claude Code ===" && npx ccusage@latest daily; echo "\n=== Codex ===" && npx @ccusage/codex@latest daily 2>/dev/null || echo "No Codex data"'
# }}}
