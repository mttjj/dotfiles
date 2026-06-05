#!/usr/bin/env bash
set -euo pipefail

# Dock
defaults write com.apple.dock tilesize -int 39
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mineffect -string scale

# Trackpad
# first click threshold = 1
defaults write com.apple.AppleMultitouchTrackpad "FirstClickThreshold" -int 1
# drag lock = 0 (false)
defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool false
# dragging = 0 (false) (this corresponds to “dragging without drag lock”)
defaults write com.apple.AppleMultitouchTrackpad "Dragging" -bool false
# three finger drag = 0 (false)
defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool false

# Mission Control
# don't rearrange Spaces automatically
defaults write com.apple.dock mru-spaces -int 0
# switch to Space with open windows (1 => true)
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool true
# separate Spaces per display (0 => off)
defaults write com.apple.spaces spans-displays -int 0

killall Dock || true