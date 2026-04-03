# OPENSPEC:START
# OpenSpec shell completions configuration
# fpath=("/Users/sahil/.zsh/completions" $fpath)
# autoload -Uz compinit
# compinit
# Commenting out - as its manageed below
# OPENSPEC:END

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

plug "zsh-users/zsh-autosuggestions"

plug "zap-zsh/supercharge"
# Theme, must be near the top
plug "romkatv/powerlevel10k"
# plug "zap-zsh/zap-prompt"

# Dev Shell
export DEVSHELL_DIR="$HOME/code/bootstrap/dev-shell"
[[ -f "$DEVSHELL_DIR/src/shell/dev.sh" ]] && source "$DEVSHELL_DIR/src/shell/dev.sh"
# Prompt Pantry
export PP_DIR="$HOME/code/bootstrap/prompt-pantry"
[[ -f "$PP_DIR/shell/rc-init.sh" ]] && source "$PP_DIR/shell/rc-init.sh"

# Claude Code
export CLAUDE_CODE_NO_FLICKER=1

#The above exports are used here
source $HOME/.zshrc_os.sh
source $HOME/.zshrc_aliases.sh
source $LIFETRACKER_DIR/secrets/zsh/.zshrc_secrets.sh

# Load and initialise completion system (optimized for performance)
autoload -Uz compinit
# Only rebuild cache once per day
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# export SSH_AUTH_SOCK=~/.1password/agent.sock # disabling SSH Agents

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# opencode
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

# bun
if [[ -s "$HOME/.bun/_bun" ]]; then
  source "$HOME/.bun/_bun"
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# linuxbrew
[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# We want this hook as late as possible so that any preivous .envrc files aren't picked up. 
#export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"   # for zsh

# Must be at the end
plug "zsh-users/zsh-syntax-highlighting"

#wt Shell wrapper
eval "$(wt shell-setup)"
