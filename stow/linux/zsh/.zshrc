# OPENSPEC:START
# OpenSpec shell completions configuration
# fpath=("/Users/sahil/.zsh/completions" $fpath)
# autoload -Uz compinit
# compinit
# Commenting out - as its manageed below
# OPENSPEC:END

#export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"   # for zsh

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

source $HOME/.zshrc_os.sh
source $HOME/.zshrc_aliases.sh
source $LIFETRACKER_DIR/secrets/zsh/.zshrc_secrets.sh

# Load and initialise completion system (optimized for performance)
autoload -Uz compinit
# Only rebuild cache once per day
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# export SSH_AUTH_SOCK=~/.1password/agent.sock # disabling SSH Agents

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Dev Shell
export DEVSHELL_DIR="/home/parallels/code/bootstrap/dev-shell"
source "$DEVSHELL_DIR/src/shell/dev.sh"

# opencode
export PATH=/home/parallels/.opencode/bin:$PATH

# bun completions
[ -s "/home/parallels/.bun/_bun" ] && source "/home/parallels/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Must be at the end
plug "zsh-users/zsh-syntax-highlighting"
