#!/usr/bin/env bash
set -euo pipefail

VOLUMES=(
  "internal-backup"
  "external-backup"
)

ASSUME_YES=0
if [ "${1:-}" = "--assume-yes" ]; then
  ASSUME_YES=1
fi

have_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! have_cmd diskutil || ! have_cmd sudo; then
  echo "Missing required commands (diskutil/sudo). Skipping auto-mount disable." >&2
  exit 0
fi

# For non-interactive runs: don't let sudo hang waiting for a password.
SUDO_OK=0
if sudo -n true 2>/dev/null; then
  SUDO_OK=1
fi

trim() {
  # trim leading/trailing whitespace
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]*}"}"
  printf '%s' "$s"
}

get_volume_uuid() {
  local vol="$1"
  local uuid
  uuid="$(diskutil info "$vol" 2>/dev/null | awk -F': ' '/^[[:space:]]*Volume UUID:/{print $2; exit}')"
  uuid="$(trim "$uuid")"
  printf '%s' "$uuid"
}

# Escape UUID for use in grep -E regex
regex_escape() {
  printf '%s' "$1" | sed 's/[][(){}.^$+*?|\\/]/\\&/g'
}

line_for_uuid() {
  local uuid="$1"
  echo "UUID=${uuid} none apfs rw,noauto"
}

already_in_fstab_for_uuid() {
  local uuid="$1"
  local u_esc
  u_esc="$(regex_escape "$uuid")"

  # Match ignoring any whitespace after "UUID=" and before the UUID
  sudo grep -Eq "^[[:space:]]*UUID=[[:space:]]*${u_esc}[[:space:]]+none[[:space:]]+apfs[[:space:]]+rw,noauto[[:space:]]*$" /etc/fstab
}

append_to_fstab() {
  local line="$1"
  echo "$line" | sudo tee -a /etc/fstab >/dev/null
}

declare -a statuses=()
added=0
already=0
skipped_no_uuid=0
skipped_sudo=0

if [ "$ASSUME_YES" -ne 1 ]; then
  echo "==> Disabling auto-mount in /etc/fstab (requires sudo)"
  echo
  echo "Volumes:"
  printf '  - %s\n' "${VOLUMES[@]}"
  echo
  read -r -p "Proceed? [y/N]: " yn
  case "$yn" in
    y|Y) ;;
    *) echo "Cancelled."; exit 0 ;;
  esac
fi

if [ "$SUDO_OK" -ne 1 ]; then
  echo "sudo -n (non-interactive) failed. Not changing /etc/fstab to avoid a prompt hang." >&2
  skipped_sudo=1
fi

for vol in "${VOLUMES[@]}"; do
  if [ "$SUDO_OK" -ne 1 ]; then
    statuses+=("$vol: SKIPPED (sudo not authorized for non-interactive mode)")
    continue
  fi

  uuid="$(get_volume_uuid "$vol" || true)"
  if [ -z "$uuid" ]; then
    statuses+=("$vol: SKIPPED (could not determine volume UUID)")
    skipped_no_uuid=$((skipped_no_uuid + 1))
    continue
  fi

  line="$(line_for_uuid "$uuid")"

  if already_in_fstab_for_uuid "$uuid"; then
    statuses+=("$vol: OK (already configured in /etc/fstab)")
    already=$((already + 1))
  else
    echo "Adding to /etc/fstab: $vol ($uuid)"
    append_to_fstab "$line"
    statuses+=("$vol: OK (added entry)")
    added=$((added + 1))
  fi
done

echo
echo "==> Auto-mount disable summary"
echo "  Added:   $added"
echo "  Already: $already"
echo "  Skipped (no UUID): $skipped_no_uuid"
if [ "$skipped_sudo" -eq 1 ]; then
  echo "  Skipped (sudo non-interactive not authorized): 1"
fi
echo
for s in "${statuses[@]}"; do
  echo "  - $s"
done

echo
echo "==> Auto-mount disable complete"
