# mac-bootstrap

Personal bootstrap configs and setup scripts for macOS development.

This repo is designed to be cloned to `~/Developer/mac-bootstrap` and used as the source of truth for your shell, Git, and developer tooling.

## Requirements

- macOS
- Git
- Homebrew (the script installs it if missing)
- zsh (default shell on macOS Catalina+)

## What This Does

- Installs Xcode Command Line Tools (if needed)
- Installs Homebrew (if needed)
- Symlinks mac-bootstrap config files into your home directory
- Runs `brew bundle` using this repo's `Brewfile`
- Installs Temurin JDK 17 and configures `jenv`
- Installs NVM and Node (or uses `.nvmrc`), and ensures global npm tools
- Creates an SSH key if one does not exist

## Quickstart

1. Clone the repo:

```zsh
git clone git@github.com:yourname/mac-bootstrap.git ~/Developer/mac-bootstrap
```

2. Run the installer:

```zsh
cd ~/Developer/mac-bootstrap
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh

sourcezsh
```

3. (Optional) Open a new terminal tab to ensure all shell config changes load.

## Dry Run

Preview all actions without making changes:

```zsh
./scripts/bootstrap.sh --dry-run
```

## Contents

| Item | Details |
| --- | --- |
| `Brewfile` | Homebrew packages (docker, maven, nvm, nx, yarn) and casks (bruno, iterm2, rectangle, visual-studio-code) |
| `scripts/` | setup scripts (`bootstrap.sh`, `grabsecrets.sh`) |
| `zsh/` | zsh configuration (`.zshrc`, `aliases.zsh`, `exports.zsh`) |
| `git/`, `nvm/` | additional configs and helpers |

## Usage

- Run `./scripts/bootstrap.sh` to install all tools, link configs, and configure Git and SSH.
- Use the aliases in `zsh/aliases.zsh` for quick navigation (e.g. `dev`, `backend`, `bootstrap`).
- Edit config files directly in this repo; changes apply immediately after sourcing `~/.zshrc`.
- Run `./scripts/grabsecrets.sh` to pull secrets needed for local setup.

## Configuration Notes

- **Repo location**: The script expects this repo at `~/Developer/mac-bootstrap`. If you want a different location, update `BOOTSTRAP` in `scripts/bootstrap.sh` and `ZDOTDIR` in `zsh/.zshenv`.
- **Git identity**: The script symlinks `git/.gitconfig` to `~/.gitconfig`. Update `git/.gitconfig` with your name and email.
- **Node version**: Update `nvm/.nvmrc` to set your preferred default.
- **Brewfile**: Add or remove packages in `Brewfile` to control Homebrew installs.
- **Java version**: The Brewfile installs Temurin JDK 17 (`temurin@17`). The bootstrap script registers it with `jenv` and sets it as the global version.
- **jenv init**: Ensure `jenv` is initialized in your shell (`jenv init -`). If it is missing, add it to your `.zshrc`.
- **Zsh load order**: `.zshenv` sets `ZDOTDIR`, and `.zshrc` sources `exports.zsh` and `aliases.zsh`.

## Homebrew & Manual Installs

When running `brew bundle` (via `scripts/bootstrap.sh`):
- **Already installed via Homebrew** — skips reinstall.
- **Manually downloaded or web-installed apps** — `brew bundle` will not detect them; it may install the Homebrew version alongside.
- **Best practice** — document manually-installed tools separately and list Homebrew-managed packages clearly in `Brewfile`.

## Optional Tools: SDKMAN

**SDKMAN** (Software Development Kit Manager) is not installed by the automated bootstrap. If you prefer SDKMAN over `jenv`, install it manually:

1. Install SDKMAN:
```zsh
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

2. Install a Java version (e.g., Java 17):
```zsh
sdk install java 17.0.10-tem
sdk default java 17.0.10-tem
```

3. Add SDKMAN init to your shell config if needed:
```zsh
echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.zshrc
echo '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"' >> ~/.zshrc
```

## Notes

- Review `scripts/bootstrap.sh` before running to understand what will be changed.
- `ZDOTDIR` is set in `zsh/.zshenv`, which controls where zsh loads `.zshrc`, `.zprofile`, and related files.
- The script uses `Brewfile` from this repo (`~/Developer/mac-bootstrap/Brewfile`).
- Customize any files after installation to fit your workflow.
- For apps already installed outside Homebrew, either add them to `Brewfile` (so Homebrew tracks them) or avoid running `brew bundle` for those specific packages.

## Troubleshooting

- **Xcode Command Line Tools keeps prompting**: Run `xcode-select --install`, wait for completion, then re-run the script.
- **Homebrew not found after install (Apple Silicon)**: Open a new terminal or run `eval "$(/opt/homebrew/bin/brew shellenv)"` before re-running.
- **`zsh: operation not permitted: ./bootstrap.sh`**: macOS may have quarantined files from the clone. From the `scripts/` directory, run `xattr -dr com.apple.quarantine .`, then retry `./bootstrap.sh`.
- **`nvm` not found**: Ensure `brew` is on PATH and that `.zprofile` is loaded (new terminal tab). You can also run `source ~/.zprofile` manually.
- **`brew bundle` fails**: Check network access and Homebrew taps; re-run with `brew bundle --file ~/Developer/mac-bootstrap/Brewfile --no-upgrade` to see errors.
- **SSH key already exists**: The script only creates `~/.ssh/id_ed25519` if missing. If you want a new key, move the existing key first.
- **Git identity missing**: Update `git/.gitconfig`, then ensure it is symlinked to `~/.gitconfig` (the script does this during the mac-bootstrap linking step).

