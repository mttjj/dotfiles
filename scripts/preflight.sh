#!/bin/bash
set -e

# Check for Xcode Command Line Tools
if ! command -v git &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Please complete the installation and run this script again."
    exit 0
fi

echo "🔑 GitHub SSH Key Setup"
echo "======================="
echo ""

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

# Check if key already exists
if [ -f "$SSH_KEY_PATH" ]; then
    echo "✓ SSH key already exists at $SSH_KEY_PATH"
    echo ""
    read -p "Use existing key? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing key."
    else
        echo "Generating new key..."
        ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$SSH_KEY_PATH" -N ""
    fi
else
    echo "Generating new SSH key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$SSH_KEY_PATH" -N ""
fi

echo ""
echo "✓ SSH key ready at $SSH_KEY_PATH"
echo ""
echo "Next steps:"
echo "1. Copy this public key:"
cat "$SSH_KEY_PATH.pub"
echo ""
echo "2. Add it to GitHub:"
echo "   → Go to https://github.com/settings/keys"
echo "   → Click 'New SSH key'"
echo "   → Paste the key above"
echo "   → Click 'Add SSH key'"
echo ""
echo "3. Verify the connection:"
ssh-keygen -R github.com 2>/dev/null || true
if ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✓ SSH connection to GitHub verified!"
else
    echo "⚠ SSH connection not yet verified (expected if key not added to GitHub yet)"
    echo "  Run 'ssh -T git@github.com' after adding the key"
fi
echo ""
