#!/usr/bin/env bash
set -u -o pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAS_APPS_FILE="$DOTFILES_ROOT/MasApps.txt"

if ! command -v mas >/dev/null 2>&1; then
  echo "mas CLI not found; skipping MAS app installs."
  exit 0
fi

if [ ! -f "$MAS_APPS_FILE" ]; then
  echo "No $MAS_APPS_FILE found; skipping MAS app installs."
  exit 0
fi

echo "==> Installing MAS apps"

installed="$(mas list 2>/dev/null | awk '{print $1}' || true)"
installed_count=0
skipped_count=0

while IFS= read -r line; do
  line="${line%%#*}"
  line="$(echo "$line" | xargs || true)"
  [ -z "$line" ] && continue

  if echo "$installed" | grep -qx "$line"; then
    skipped_count=$((skipped_count + 1))
    continue
  fi

  if mas install "$line" 2>/dev/null; then
    installed_count=$((installed_count + 1))
  else
    echo "Failed to install MAS app $line (continuing)." >&2
  fi
done < "$MAS_APPS_FILE"

echo "==> MAS apps installation complete (installed: $installed_count, already present: $skipped_count)"
