#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./link.sh <source_file> <dest_path>

source_file="${1:?source_file required}"
dest_path="${2:?dest_path required}"

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

abspath() {
  local p="$1"
  if [[ "$p" == /* ]]; then
    echo "$p"
  else
    echo "$(cd "$(dirname "$p")" && pwd)/$(basename "$p")"
  fi
}

source_abs="$(abspath "$source_file")"
dest_dir="$(dirname "$dest_path")"
mkdir -p "$dest_dir"

# If dest already symlinks to the right file, do nothing
if [ -L "$dest_path" ]; then
  target="$(readlink "$dest_path" || true)"
  if [[ "$target" == /* ]]; then
    target_abs="$(abspath "$target")"
  else
    target_abs="$(abspath "$dest_dir/$target")"
  fi

  if [ "$target_abs" = "$source_abs" ]; then
    exit 0
  fi
fi

# If dest exists but isn't the right symlink, back it up then replace
if [ -e "$dest_path" ] || [ -L "$dest_path" ]; then
  ts="$(date +%Y%m%d%H%M%S)"
  backup="${dest_path}.bak.${ts}"
  mv "$dest_path" "$backup"
fi

ln -s "$source_abs" "$dest_path"
