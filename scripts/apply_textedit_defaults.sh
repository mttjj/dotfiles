#!/usr/bin/env bash
set -euo pipefail

# TextEdit
defaults write com.apple.TextEdit RichText -int 0

killall TextEdit 2>/dev/null || true
