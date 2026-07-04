#!/bin/bash

set -u -o pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$DOTFILES_ROOT/DeveloperApps.txt"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Developer apps config not found at $CONFIG_FILE"
    exit 1
fi

installed_count=0
skipped_count=0

while IFS='|' read -r app_name download_url installed_path file_type; do
    # Skip comments and empty lines
    [[ "$app_name" =~ ^# ]] && continue
    [[ -z "$app_name" ]] && continue

    # Trim whitespace
    app_name=$(echo "$app_name" | xargs)
    download_url=$(echo "$download_url" | xargs)
    installed_path=$(echo "$installed_path" | xargs)
    file_type=$(echo "$file_type" | xargs)

    # Check if already installed
    if [[ -d "$installed_path" ]]; then
        echo "Skipped $app_name (already installed)"
        ((skipped_count++))
        continue
    fi

    temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    case "$app_name" in
        "Komga")
            # Parse komga download page to find latest Apple Silicon (aarch64) zip
            echo "Downloading $app_name..."
            download_link=$(curl -s "$download_url" | grep -oE 'https://[^"]*mac-aarch64\.zip' | head -1)

            if [[ -z "$download_link" ]]; then
                echo "Error: Could not find Apple Silicon (aarch64) download link for Komga" >&2
                continue
            fi

            zip_file="$temp_dir/komga.zip"
            curl -sL -o "$zip_file" "$download_link" || {
                echo "Error: Failed to download Komga" >&2
                continue
            }

            unzip -q "$zip_file" -d /Applications/ || {
                echo "Error: Failed to extract Komga" >&2
                continue
            }

            echo "Installed $app_name"
            ((installed_count++))
            ;;

        "XLD")
            # Parse XLD page to find latest DMG download link
            echo "Downloading $app_name..."
            dmg_link=$(curl -s "$download_url" | grep -o 'href=[^ ]*xld-[^ ]*\.dmg' | sed 's/href=//' | head -1)

            if [[ -z "$dmg_link" ]]; then
                echo "Error: Could not find DMG download link for XLD" >&2
                continue
            fi

            dmg_file="$temp_dir/xld.dmg"
            curl -sL -o "$dmg_file" "$dmg_link" || {
                echo "Error: Failed to download XLD" >&2
                continue
            }

            # Mount DMG, copy app, eject
            mount_point=$(mktemp -d)
            hdiutil mount -quiet -mountpoint "$mount_point" "$dmg_file" || {
                echo "Error: Failed to mount XLD DMG" >&2
                rm -rf "$mount_point"
                continue
            }

            # Find the .app bundle in the mounted volume
            app_bundle=$(find "$mount_point" -maxdepth 1 -name "*.app" -type d | head -1)
            if [[ -z "$app_bundle" ]]; then
                echo "Error: No .app found in XLD DMG" >&2
                hdiutil eject -quiet "$mount_point" 2>/dev/null || true
                rm -rf "$mount_point"
                continue
            fi

            cp -r "$app_bundle" /Applications/ || {
                echo "Error: Failed to copy XLD to /Applications" >&2
                hdiutil eject -quiet "$mount_point" 2>/dev/null || true
                rm -rf "$mount_point"
                continue
            }

            hdiutil eject -quiet "$mount_point" || true
            rm -rf "$mount_point"

            echo "Installed $app_name"
            ((installed_count++))
            ;;

        *)
            echo "Unknown app type: $app_name" >&2
            ;;
    esac

    trap - EXIT
    rm -rf "$temp_dir"

done < "$CONFIG_FILE"

echo ""
echo "Developer apps: $installed_count installed, $skipped_count skipped"
