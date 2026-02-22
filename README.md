# Dotfiles

Personal dotfiles and setup scripts for macOS development.

## Quickstart

1. Clone the repo:

```bash
git clone git@github.com:yourname/dotfiles.git ~/Developer/dotfiles
```

2. Run the installer:

```bash
cd ~/Developer/dotfiles
chmod +x install.sh
./install.sh

source ~/.zshrc
```

3. (Optional) Install Homebrew packages from the Brewfile:
```bash
brew bundle
```

## Requirements

- macOS
- Git
- Homebrew (for `brew bundle`)

## Contents

- `Brewfile` — Homebrew packages and casks
- `zsh/` — zsh configuration (`.zshrc`, `aliases.zsh`, `exports.zsh`)
- `git/`, `nvm/`, `yarn/` — additional configs and helpers

## Usage

- Run `./install.sh` to symlink config files into your home directory and perform initial setup.
- Use the aliases in `zsh/aliases.zsh` for quick navigation (e.g. `dev`, `backend`).

## Notes

- Review `install.sh` before running to understand what will be changed.
- Customize any files after installation to fit your workflow.

---
