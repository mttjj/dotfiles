# iTerm2 often starts interactive *non-login* shells, so source .zprofile manually
[ -r "$HOME/.zprofile" ] && source "$HOME/.zprofile"

# modular bits
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"
[ -f "$HOME/.functions" ] && source "$HOME/.functions"

# pyenv (minimal)
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

# zsh-syntax-highlighting (fail-safe)
if command -v brew >/dev/null 2>&1; then
  SH_PATH="$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [ -f "$SH_PATH" ] && source "$SH_PATH"
fi
