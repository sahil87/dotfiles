#!/bin/zsh
# macOS-specific aliases and overrides (sourced by .zshrc_aliases.sh)

alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'

# Set terminal tab/window title (persists across prompts)
# Ghostty's _ghostty_precmd resets the title on every prompt and fights to
# stay last in precmd_functions. We append to _ghostty_precmd itself so our
# override always runs after Ghostty's title-setter.
tabname() {
    if [[ -n "$*" ]]; then
        _TABNAME_OVERRIDE="$*"
        printf '\033]2;%s\007' "$*"
    else
        unset _TABNAME_OVERRIDE
    fi
}
alias tn='tabname'
alias trs='tabname'  # call with no args to reset

# After Ghostty's deferred init runs, append our override to _ghostty_precmd
_tabname_hook_ghostty() {
    if (( $+functions[_ghostty_precmd] )); then
        functions[_ghostty_precmd]+='
            [[ -n "$_TABNAME_OVERRIDE" ]] && builtin print -nu 1 "\e]2;${_TABNAME_OVERRIDE}\a"'
    fi
    precmd_functions=(${(@)precmd_functions:#_tabname_hook_ghostty})
}
precmd_functions+=(_tabname_hook_ghostty)
