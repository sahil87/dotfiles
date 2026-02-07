# Default file exposed to non-interactive zsh shells also
export PATH="/usr/local/bin:$PATH"

export BOOTSTRAP_DIR=`realpath $HOME/code/bootstrap`
export DEVSHELL_DIR=`realpath $BOOTSTRAP_DIR/dev-shell`
export DOTFILES_DIR=`realpath $BOOTSTRAP_DIR/dotfiles`
export LIFETRACKER_DIR=`realpath $BOOTSTRAP_DIR/lifetracker`
export PP_DIR=`realpath $BOOTSTRAP_DIR/prompt-pantry`
export BLOG_DIR=`realpath $BOOTSTRAP_DIR/blog2020`

export MORNING_UPDATES_DIR=`realpath $LIFETRACKER_DIR/cc-morning-updates`
export CHATS_DIR=`realpath $LIFETRACKER_DIR/cc-chats`
export CCSCRIPTS_DIR=`realpath $LIFETRACKER_DIR/scripts/cc`
