# Dotfiles

Personal dotfiles and setup scripts for macOS development.

## Requirements

- macOS
- Git
- Homebrew (for `brew bundle`)

## Quickstart

1. Clone the repo:

```bash
git clone git@github.com:yourname/dotfiles.git ~/Developer/dotfiles
```

2. Run the installer:

```bash
cd ~/Developer/dotfiles
chmod +x bootstrap.sh
./bootstrap.sh

source ~/.zshrc
```

3. (Optional) Install Homebrew packages from the Brewfile:
```bash
brew bundle
```

## Contents

- `Brewfile` — Homebrew packages and casks
- `zsh/` — zsh configuration (`.zshrc`, `aliases.zsh`, `exports.zsh`)
- `git/`, `nvm/`, `yarn/` — additional configs and helpers

## Usage

- Run `./bootstrap.sh` to install all tools, link dotfiles, and configure Git and SSH.
- Use the aliases in `zsh/aliases.zsh` for quick navigation (e.g. `dev`, `backend`, `dotfiles`).
- Edit config files directly in this repo; changes apply immediately after sourcing `~/.zshrc`.

## Homebrew & Manual Installs

When running `brew bundle`:
- **Already installed via Homebrew** — skips reinstall.
- **Manually downloaded or web-installed apps** — `brew bundle` will not detect them; it may install the Homebrew version alongside.
- **Best practice** — document manually-installed tools separately and list Homebrew-managed packages clearly in `Brewfile`.

## Notes

- Review `bootsrap.sh` before running to understand what will be changed.
- Customize any files after installation to fit your workflow.
- For apps already installed outside Homebrew, either add them to `Brewfile` (so Homebrew tracks them) or avoid running `brew bundle` for those specific packages.

