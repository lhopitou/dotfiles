ZPLUGINDIR="$XDG_CACHE_HOME/zsh/plugins"

_zplugin_load() {
  local author repo
  IFS="/" read -r author repo <<< "$1"
  local plugin_path="${ZPLUGINDIR}/${repo}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${repo}..."
    git clone --depth=1 "https://github.com/${author}/${repo}" "$plugin_path" \
      || { echo "ERROR: failed to install ${repo}" >&2; return 1; }
  fi
  source "${plugin_path}/${repo}.plugin.zsh"
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

_zplugin_load zsh-users/zsh-autosuggestions
eval "$(${ZPLUGINDIR}/zsh-patina/zsh-patina activate)"
