#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ITERM2_CONFIG_DIR="$DOTFILES_ROOT/files/.config/iterm2"

echo "==> Applying iTerm2 defaults"

# Ensure iTerm2 config directory exists
mkdir -p "$ITERM2_CONFIG_DIR"

# Set iTerm2 to use custom preferences folder
# This tells iTerm2 to load settings from the dotfiles repo
defaults write com.googlecode.iterm2 PreferencesBundleLocation -string "$ITERM2_CONFIG_DIR"

# Enable automatic profile saving (optional but recommended)
defaults write com.googlecode.iterm2 AutoSaveProfileDirectory -string "$ITERM2_CONFIG_DIR"

killall iTerm2 2>/dev/null || true

echo "==> iTerm2 defaults applied"
