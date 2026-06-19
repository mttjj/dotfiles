#!/usr/bin/env bash
set -euo pipefail

echo "==> Applying Safari defaults"

# Safari
defaults write com.apple.Safari ShowFullURL -int 1

killall Safari 2>/dev/null || true

echo "==> Safari defaults applied"
