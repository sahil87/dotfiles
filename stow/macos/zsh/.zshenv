# Default file exposed to non-interactive zsh shells also
export PATH="/usr/local/bin:$PATH"

# Helper: export var only if directory exists
_dir_export() { [[ -d "$2" ]] && export "$1"="$2"; }

# Core (always expected to exist)
export BOOTSTRAP_DIR="$HOME/code/bootstrap"
export DOTFILES_DIR="$BOOTSTRAP_DIR/dotfiles"
export LIFETRACKER_DIR="$BOOTSTRAP_DIR/lifetracker"

# ~/code/sahil87 (optional)
_dir_export BLOG_DIR    "$HOME/code/sahil87/blog2020"
_dir_export OUTBOX_DIR  "$HOME/code/sahil87/outbox"

# ~/code/sahil-weaver (optional)
_dir_export PP_DIR      "$HOME/code/sahil-weaver/prompt-pantry"
_dir_export DEVSHELL_DIR "$HOME/code/wvrdz/dev-shell"

# Lifetracker subdirs
export MORNING_UPDATES_DIR="$LIFETRACKER_DIR/cc-morning-updates"
export CHATS_DIR="$LIFETRACKER_DIR/cc-chats"
export CCSCRIPTS_DIR="$LIFETRACKER_DIR/scripts/cc"
