#!/usr/bin/env bash
set -euo pipefail

echo "==> Applying Finder defaults"

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Preferred view style: List
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv

# Sort folders first
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Disable extension change warning
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool false

# Table view default size mode
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int 1

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Desktop: drives/media visibility
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

killall Finder 2>/dev/null || true

echo "==> Finder defaults applied"
