#!/bin/bash
set -e

echo "🔑 GitHub SSH Key Setup"
echo "======================="
echo ""

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

echo "Generating SSH key..."
ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$SSH_KEY_PATH" -N ""

echo ""
echo "✓ SSH key generated"
echo ""
echo "Next steps:"
echo ""
echo "1. Copy this public key:"
cat "$SSH_KEY_PATH.pub"
echo ""
echo "2. Add it to GitHub:"
echo "   → Go to https://github.com/settings/keys"
echo "   → Click 'New SSH key'"
echo "   → Paste the key above"
echo "   → Click 'Add SSH key'"
echo ""
echo "3. Verify connection:"
echo "   ssh -T git@github.com"
echo ""
