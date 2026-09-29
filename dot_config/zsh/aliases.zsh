alias ls='eza --icons auto'
alias lsa='eza -alh --icons --git --group-directories-first'
compdef eza=ls

alias grep='grep --color=auto'
alias cp='cp -iv'
alias free='free -h'
alias mv='mv -iv'
alias rm='rm -iv'
alias cat='bat --color=always'
alias cd='z'
alias nvm='fnm'
alias zj='zellij'
alias c='clear'
alias so='source $ZDOTDIR/.zshrc'

alias lazy='NVIM_APPNAME=lazy nvim'
alias cz='chezmoi'

fnm-gi() {
  npm install -g --ignore-scripts $(fnm exec npm ls -g --json | jq -r '.dependencies | del(.npm, .corepack) | to_entries | map("\(.key)@\(.value.version)") | join(" ")')
}
