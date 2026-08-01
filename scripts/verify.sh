#!/usr/bin/env bash
set -u -o pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

have_cmd() { command -v "$1" >/dev/null 2>&1; }

check_symlink() {
  local src="$1"
  local dst="$2"
  if [ ! -L "$dst" ]; then
    if [ -e "$dst" ]; then
      echo "  ❌ $dst exists but is not a symlink"
      return 1
    else
      echo "  ⚠️  $dst not yet linked"
      return 2
    fi
  else
    local target="$(readlink "$dst")"
    if [ "$target" != "$src" ]; then
      echo "  ❌ $dst points to $target, not $src"
      return 1
    fi
    echo "  ✓ $dst"
    return 0
  fi
}

echo "==> Dotfiles Verification"
echo

# Check symlinks
echo "Checking symlinks..."
all_ok=0
check_symlink "$DOTFILES_ROOT/files/.zshrc" "$HOME/.zshrc" || all_ok=$?
check_symlink "$DOTFILES_ROOT/files/.zprofile" "$HOME/.zprofile" || all_ok=$?
check_symlink "$DOTFILES_ROOT/files/.aliases" "$HOME/.aliases" || all_ok=$?
check_symlink "$DOTFILES_ROOT/files/.functions" "$HOME/.functions" || all_ok=$?
check_symlink "$DOTFILES_ROOT/files/.brew-env" "$HOME/.brew-env" || all_ok=$?
check_symlink "$DOTFILES_ROOT/files/.ssh/config" "$HOME/.ssh/config" || all_ok=$?
check_symlink "$DOTFILES_ROOT/files/.pyenv/version" "$HOME/.pyenv/version" || all_ok=$?
check_symlink "$DOTFILES_ROOT/files/.gitconfig" "$HOME/.gitconfig" || all_ok=$?
check_symlink "$DOTFILES_ROOT/files/.config/git/ignore" "$HOME/.config/git/ignore" || all_ok=$?

echo

# Check tools
echo "Checking installed tools..."
tools=(brew python pyenv hugo git ssh)
for tool in "${tools[@]}"; do
  if have_cmd "$tool"; then
    echo "  ✓ $tool"
  else
    echo "  ⚠️  $tool not found"
    all_ok=1
  fi
done

echo

# Check Python version
if have_cmd pyenv; then
  pyver=$(cat "$HOME/.pyenv/version" 2>/dev/null | head -n1 || echo "unknown")
  echo "Python version preference: $pyver"
  current=$(pyenv version 2>/dev/null | awk '{print $1}' || echo "none")
  if [ "$current" = "$pyver" ]; then
    echo "  ✓ Current Python version matches"
  else
    echo "  ⚠️  Current version is $current, preference is $pyver"
  fi
fi

echo

# Summary
if [ $all_ok -eq 0 ]; then
  echo "✓ All checks passed"
  exit 0
else
  echo "⚠️  Some checks failed or returned warnings"
  echo "Run './scripts/update.sh' to fix symlink issues"
  exit 1
fi
