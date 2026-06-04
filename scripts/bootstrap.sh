#!/usr/bin/env bash
set -u -o pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link() {
  local src="$1"
  local dst="$2"
  if [ -e "$src" ]; then
    "$DOTFILES_ROOT/scripts/link.sh" "$src" "$dst" || echo "Link failed: $dst (continuing)"
  else
    echo "Missing source: $src (skipping link to $dst)"
  fi
}

# 1) Symlinks
link "$DOTFILES_ROOT/files/.zshrc" "$HOME/.zshrc"
link "$DOTFILES_ROOT/files/.zprofile" "$HOME/.zprofile"
link "$DOTFILES_ROOT/files/.aliases" "$HOME/.aliases"
link "$DOTFILES_ROOT/files/.functions" "$HOME/.functions"
link "$DOTFILES_ROOT/files/.brew-env" "$HOME/.brew-env"
link "$DOTFILES_ROOT/files/.ssh/config" "$HOME/.ssh/config"
link "$DOTFILES_ROOT/files/.pyenv/version" "$HOME/.pyenv/version"

# Git global config + global ignore
link "$DOTFILES_ROOT/files/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_ROOT/files/.config/git/ignore" "$HOME/.config/git/ignore"

# Ensure Git uses the global ignore file
if command -v git >/dev/null 2>&1; then
  mkdir -p "$HOME/.config/git"
  git config --global core.excludesfile "$HOME/.config/git/ignore" || echo "git core.excludesfile failed (continuing)"
fi

# 2) Brew bundle
if command -v brew >/dev/null 2>&1; then
  if [ -f "$DOTFILES_ROOT/Brewfile" ]; then
    brew bundle --file "$DOTFILES_ROOT/Brewfile" || echo "brew bundle failed (continuing)"
  else
    echo "No Brewfile found at $DOTFILES_ROOT/Brewfile; skipping brew bundle."
  fi
else
  echo "Homebrew not found; skipping brew bundle."
fi

# 3) pyenv install + global
if command -v pyenv >/dev/null 2>&1; then
  if [ -f "$HOME/.pyenv/version" ]; then
    VER="$(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$HOME/.pyenv/version" | head -n1)"
    if [ -n "$VER" ]; then
      pyenv install -s "$VER" || echo "pyenv install failed for $VER (continuing)"
      pyenv global "$VER" || echo "pyenv global failed for $VER (continuing)"
    else
      echo "Could not parse a version from $HOME/.pyenv/version"
    fi
  else
    echo "No $HOME/.pyenv/version found; skipping pyenv install."
  fi
else
  echo "pyenv not found; skipping pyenv install."
fi

# 4) MAS apps
if [ -x "$DOTFILES_ROOT/scripts/install_mas_apps.sh" ]; then
  "$DOTFILES_ROOT/scripts/install_mas_apps.sh" || echo "MAS install step failed (continuing)"
fi

echo "Done."
