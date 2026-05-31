#!/usr/bin/env bash
set -u -o pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAS_APPS_FILE="$DOTFILES_ROOT/MasApps.txt"

if ! command -v mas >/dev/null 2>&1; then
  echo "mas CLI not found; skipping MAS app installs."
  exit 0
fi

if [ ! -f "$MAS_APPS_FILE" ]; then
  echo "No $MAS_APPS_FILE found; skipping MAS app installs."
  exit 0
fi

installed="$(mas list 2>/dev/null | awk '{print $1}' || true)"

while IFS= read -r line; do
  line="${line%%#*}"
  line="$(echo "$line" | xargs || true)"
  [ -z "$line" ] && continue

  if echo "$installed" | grep -qx "$line"; then
    echo "MAS app $line already installed; skipping."
    continue
  fi

  echo "Installing MAS app $line..."
  if mas install "$line"; then
    echo "Installed $line."
  else
    echo "Failed to install $line (continuing)."
  fi
done < "$MAS_APPS_FILE"
