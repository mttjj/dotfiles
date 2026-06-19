#!/usr/bin/env bash
set -euo pipefail

echo "==> Applying TextEdit defaults"

# TextEdit
defaults write com.apple.TextEdit RichText -int 0

killall TextEdit 2>/dev/null || true

echo "==> TextEdit defaults applied"
