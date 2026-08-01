# dotfiles

A macOS dotfiles setup repository for bootstrapping a new machine with tools, configurations, and system defaults.

## Contents

- **files/** — Configuration files (shell, git, ssh, pyenv)
- **scripts/** — Setup and configuration scripts
- **Brewfile** — Homebrew packages and casks
- **MasApps.txt** — Mac App Store apps to install via `mas`

## Quick Start

### 1. Preflight Steps

1. Install developer commandline tools
    - Open Terminal and run: `xcode-select --install`

2. Generate an SSH key to authenticate with GitHub
    - Open Terminal and run: `curl -fsSL https://raw.githubusercontent.com/mttjj/dotfiles/main/scripts/preflight.sh | bash`

### 2. Clone and bootstrap

```bash
git clone git@github.com:mttjj/dotfiles.git ~/.dotfiles
~/.dotfiles/scripts/bootstrap.sh
```

The bootstrap script provides an interactive menu:

1. **Symlink dotfiles** — Link shell configs, git config, SSH config, etc. to home directory
2. **Install Homebrew** — Bootstrap Homebrew if not present
3. **Install apps** — Run `brew bundle`, install Python via pyenv, Hugo, and MAS apps
4. **Set app defaults** — Apply macOS defaults for System, Finder, Safari, TextEdit
5. **Disable backup auto-mount** — Prevent Time Machine backup drive auto-mounting
6. **Do everything** — Run all steps non-interactively

Choose individual steps or run "6" for a complete unattended setup.

## Files

- **.zshrc / .zprofile** — Zsh configuration
- **.aliases / .functions** — Shell aliases and functions
- **.gitconfig** — Git configuration
- **.config/git/ignore** — Global git ignore rules
- **.ssh/config** — SSH configuration
- **.pyenv/version** — Python version (installed via pyenv)
- **.brew-env** — Homebrew environment variables

## Scripts

- **bootstrap.sh** — Main interactive setup orchestrator
- **apply_*.sh** — Set macOS app defaults (System, Finder, Safari, TextEdit)
- **disable_backup_auto_mount.sh** — Prevent Time Machine auto-mounting
- **install_hugo_0_141_0.sh** — Install specific Hugo version
- **install_mas_apps.sh** — Install MAS apps from MasApps.txt
- **link.sh** — Symlink utility (handles backups of existing files)

### Maintenance

- **verify.sh** — Check that all symlinks and tools are working correctly
