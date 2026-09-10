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

# ~/code/sahil-noon (optional)
_dir_export PP_DIR      "$HOME/code/sahil-noon/prompt-pantry"
_dir_export DEVSHELL_DIR "$HOME/code/wvrdz/dev-shell"

# Lifetracker subdirs
# export CCSCRIPTS_DIR="$LIFETRACKER_DIR/scripts/cc"

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
# >>> rk tmux guard >>>
export PATH="$HOME/.local/share/rk/shims:$PATH"
# <<< rk tmux guard <<<
# >>> rk gui display >>>
# .zshenv runs before brew's PATH is set up, so probe the known brew prefixes
# (Linuxbrew, Apple Silicon Homebrew) before falling back to PATH.
if [ -n "$TMUX_PANE" ] && [ -z "${DISPLAY-}" ]; then
  for _rk in /home/linuxbrew/.linuxbrew/bin/run-kit /opt/homebrew/bin/run-kit "$(command -v run-kit 2>/dev/null)"; do
    if [ -n "$_rk" ] && [ -x "$_rk" ]; then
      eval "$("$_rk" gui env 2>/dev/null)"
      break
    fi
  done
  unset _rk
fi
# <<< rk gui display <<<
