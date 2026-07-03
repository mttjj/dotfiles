#!/usr/bin/env bash
set -u -o pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

have_cmd() { command -v "$1" >/dev/null 2>&1; }

link_file() {
  local src="$1"
  local dst="$2"
  if [ -e "$src" ]; then
    "$DOTFILES_ROOT/scripts/link.sh" "$src" "$dst" || echo "Link failed: $dst (continuing)" >&2
  else
    echo "Missing source: $src (skipping link to $dst)" >&2
  fi
}

# -------- Symlinks --------
step_symlink() {
  echo "==> Symlinking dotfiles"

  link_file "$DOTFILES_ROOT/files/.zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_ROOT/files/.zprofile" "$HOME/.zprofile"
  link_file "$DOTFILES_ROOT/files/.aliases" "$HOME/.aliases"
  link_file "$DOTFILES_ROOT/files/.functions" "$HOME/.functions"
  link_file "$DOTFILES_ROOT/files/.brew-env" "$HOME/.brew-env"
  link_file "$DOTFILES_ROOT/files/.ssh/config" "$HOME/.ssh/config"
  link_file "$DOTFILES_ROOT/files/.pyenv/version" "$HOME/.pyenv/version"

  link_file "$DOTFILES_ROOT/files/.gitconfig" "$HOME/.gitconfig"
  link_file "$DOTFILES_ROOT/files/.config/git/ignore" "$HOME/.config/git/ignore"

  if have_cmd git; then
    mkdir -p "$HOME/.config/git"
    git config --global core.excludesfile "$HOME/.config/git/ignore" \
      || echo "git core.excludesfile failed (continuing)" >&2
  fi

  echo "==> Symlinking dotfiles complete"
}

# -------- Ensure Homebrew --------
step_install_homebrew() {
  echo "==> Installing Homebrew (if not present)"

  if have_cmd brew; then
    echo "Homebrew already installed: $(brew --prefix 2>/dev/null || true)"
    echo "==> Homebrew check complete"
    return 0
  fi

  echo "Homebrew not found; attempting install."

  if have_cmd curl; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || { echo "Homebrew install failed (continuing)." >&2; return 0; }
  else
    echo "curl not found; cannot auto-install Homebrew. Install manually and re-run." >&2
    return 0
  fi

  if [ -x "/opt/homebrew/bin/brew" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
  fi

  echo "Homebrew now: $(brew --prefix 2>/dev/null || true)"
  echo "==> Homebrew check complete"
}

# -------- Apps --------
step_install_apps() {
  echo "==> Installing apps (Homebrew bundle, pyenv, Hugo, MAS)"

  if have_cmd brew; then
    if [ -f "$DOTFILES_ROOT/Brewfile" ]; then
      echo "Running brew bundle..."
      brew bundle --file "$DOTFILES_ROOT/Brewfile" || echo "brew bundle failed (continuing)." >&2
    else
      echo "No Brewfile found at $DOTFILES_ROOT/Brewfile; skipping brew bundle." >&2
    fi
  else
    echo "Homebrew not found; skipping brew bundle." >&2
  fi

  if have_cmd pyenv; then
    if [ -f "$HOME/.pyenv/version" ]; then
      VER="$(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$HOME/.pyenv/version" | head -n1)"
      if [ -n "$VER" ]; then
        echo "Installing Python $VER via pyenv..."
        pyenv install -s "$VER" || echo "pyenv install failed for $VER (continuing)." >&2
        pyenv global "$VER" || echo "pyenv global failed for $VER (continuing)." >&2
      else
        echo "Could not parse a version from $HOME/.pyenv/version." >&2
      fi
    else
      echo "No $HOME/.pyenv/version found; skipping pyenv install." >&2
    fi
  else
    echo "pyenv not found; skipping pyenv install." >&2
  fi

  if [ -x "$DOTFILES_ROOT/scripts/install_hugo_0_141_0.sh" ]; then
    echo "Running Hugo install script..."
    "$DOTFILES_ROOT/scripts/install_hugo_0_141_0.sh" || echo "Hugo install failed (continuing)." >&2
  else
    echo "Hugo install script missing; skipping Hugo install." >&2
  fi

  if [ -x "$DOTFILES_ROOT/scripts/install_mas_apps.sh" ]; then
    "$DOTFILES_ROOT/scripts/install_mas_apps.sh" || echo "MAS install step failed (continuing)." >&2
  else
    echo "MAS install script missing; skipping MAS step." >&2
  fi

  echo "==> Installing apps complete"
}

# -------- Defaults runners --------
apply_system_defaults() {
  local system_script="$DOTFILES_ROOT/scripts/apply_system_defaults.sh"
  if [ -x "$system_script" ]; then
    "$system_script" || echo "System defaults failed (continuing)." >&2
  else
    echo "System defaults script not found: $system_script (skipping)."
  fi
}

apply_finder_defaults() {
  local finder_script="$DOTFILES_ROOT/scripts/apply_finder_defaults.sh"
  if [ -x "$finder_script" ]; then
    "$finder_script" || echo "Finder defaults failed (continuing)." >&2
  else
    echo "Finder defaults script not found: $finder_script (skipping)."
  fi
}

apply_safari_defaults() {
  local script="$DOTFILES_ROOT/scripts/apply_safari_defaults.sh"
  if [ -x "$script" ]; then
    "$script" || echo "Safari defaults failed (continuing)." >&2
  else
    echo "Safari defaults script not found: $script (skipping)."
  fi
}

apply_textedit_defaults() {
  local script="$DOTFILES_ROOT/scripts/apply_textedit_defaults.sh"
  if [ -x "$script" ]; then
    "$script" || echo "TextEdit defaults failed (continuing)." >&2
  else
    echo "TextEdit defaults script not found: $script (skipping)."
  fi
}

apply_iterm2_defaults() {
  local script="$DOTFILES_ROOT/scripts/apply_iterm2_defaults.sh"
  if [ -x "$script" ]; then
    "$script" || echo "iTerm2 defaults failed (continuing)." >&2
  else
    echo "iTerm2 defaults script not found: $script (skipping)."
  fi
}

step_app_defaults_all() {
  echo "==> Applying all app defaults (Finder, System, TextEdit, Safari, iTerm2)"

  apply_system_defaults
  apply_finder_defaults
  apply_safari_defaults
  apply_textedit_defaults
  apply_iterm2_defaults

  echo "==> All app defaults applied"
}

# -------- App defaults submenu (interactive) --------
step_app_defaults_menu() {
  while true; do
    echo "==> App defaults: select defaults to apply"
    echo
    echo "Options:"
    echo "  1) System defaults"
    echo "  2) Finder defaults"
    echo "  3) Safari defaults"
    echo "  4) TextEdit defaults"
    echo "  5) iTerm2 defaults"
    echo "  6) All defaults"
    echo "  7) Back to main menu"
    echo

    read -r -p "Selection [1-7]: " subchoice
    echo

    case "${subchoice:-7}" in
      1) apply_system_defaults ;;
      2) apply_finder_defaults ;;
      3) apply_safari_defaults ;;
      4) apply_textedit_defaults ;;
      5) apply_iterm2_defaults ;;
      6) step_app_defaults_all ;;
      7) echo "Back to main menu."; return 0 ;;
      *) echo "Unknown choice: ${subchoice}. Try again." ;;
    esac

    echo
  done
}

# -------- Disable backup auto-mount --------
step_disable_backup_auto_mount_interactive() {
  if [ -x "$DOTFILES_ROOT/scripts/disable_backup_auto_mount.sh" ]; then
    "$DOTFILES_ROOT/scripts/disable_backup_auto_mount.sh" || echo "Auto-mount disable failed (continuing)." >&2
  else
    echo "Auto-mount disable script missing; skipping."
  fi
}

step_disable_backup_auto_mount_noninteractive() {
  echo "==> Disabling backup auto-mount (non-interactive)"
  if [ -x "$DOTFILES_ROOT/scripts/disable_backup_auto_mount.sh" ]; then
    "$DOTFILES_ROOT/scripts/disable_backup_auto_mount.sh" --assume-yes || echo "Auto-mount disable failed (continuing)." >&2
  else
    echo "Auto-mount disable script missing; skipping."
  fi
}


# -------- Do everything (non-interactive) --------
step_all_noninteractive() {
  step_symlink
  step_install_homebrew
  step_install_apps
  step_app_defaults_all
  step_disable_backup_auto_mount_noninteractive

  echo "==> All steps complete"
}

# -------- Main menu --------
main_menu() {
  while true; do
    echo
    echo "=== Dotfiles Bootstrap ==="
    echo
    echo "Options:"
    echo "  1) Symlink dotfiles"
    echo "  2) Install Homebrew"
    echo "  3) Install apps (Homebrew + MAS + pyenv)"
    echo "  4) Set app defaults (interactive)"
    echo "  5) Disable backup auto-mount (requires sudo)"
    echo "  6) Do everything (non-interactive)"
    echo "  7) Exit"
    echo

    read -r -p "Selection [1-7]: " choice
    echo

    case "${choice:-7}" in
      1) step_symlink ;;
      2) step_install_homebrew ;;
      3) step_install_apps ;;
      4) step_app_defaults_menu ;;
      5) step_disable_backup_auto_mount_interactive ;;
      6) step_all_noninteractive; exit 0 ;;
      7) echo "Exiting."; exit 0 ;;
      *) echo "Unknown choice: ${choice}. Try again." ;;
    esac
  done
}

main_menu
