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

source <(fzf --zsh)
