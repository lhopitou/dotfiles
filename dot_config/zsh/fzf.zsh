export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow'
export FZF_DEFAULT_OPTS="
  --border
  --layout=reverse
"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --border
  --preview 'bat --color=always --style=numbers {}'
  --preview-window 'right:50%:wrap'
  --preview-border=left
  --bind 'ctrl-/:change-preview-window(down|hidden|right:50%)'
  --popup=center,70%
  --multi
  --cycle
"

# CTRL-R: sync in-memory history from $HISTFILE first, so commands typed in
# other shells appear without needing a fresh prompt.
fzf-history-widget-sync() {
  builtin fc -R 2>/dev/null
  builtin zle fzf-history-widget
}
zle -N fzf-history-widget-sync
bindkey -M emacs '^R' fzf-history-widget-sync
bindkey -M vicmd '^R' fzf-history-widget-sync
bindkey -M viins '^R' fzf-history-widget-sync

source <(fzf --zsh)
