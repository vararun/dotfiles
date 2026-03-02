#!/usr/bin/env zsh
# bootstrap.sh — Mac Dev Setup
# Requires zsh (default shell on macOS Catalina+)
# Usage:
#   ./bootstrap.sh              → full install
#   ./bootstrap.sh --dry-run    → print commands, execute nothing
# =============================================================================

# zsh equivalent of bash's set -euo pipefail
setopt ERR_EXIT          # -e : exit on error
setopt PIPE_FAIL         # -o pipefail : catch failures in pipes

# =============================================================================
# DRY-RUN SETUP
# zsh-native: zparseopts handles --dry-run cleanly
# =============================================================================
DRY_RUN=false
zparseopts -D -E - -dry-run=dry_run_flag 2>/dev/null || true
[[ ${#dry_run_flag} -gt 0 ]] && DRY_RUN=true

# run() — wraps every side-effecting command
# In dry-run mode: prints the command instead of executing it
run() {
  if $DRY_RUN; then
    echo "  [DRY-RUN] $*"
  else
    "$@"
  fi
}

# info/success/warn — consistent logging
COLOR_RESET="\033[0m"
COLOR_INFO="\033[36m"
COLOR_SUCCESS="\033[32m"
COLOR_WARN="\033[33m"
COLOR_SECTION="\033[35m"
info()    { echo "${COLOR_INFO}  → $*${COLOR_RESET}"; }
success() { echo "${COLOR_SUCCESS}  ✓ $*${COLOR_RESET}"; }
warn()    { echo "${COLOR_WARN}  ⚠ $*${COLOR_RESET}"; }
section() { echo ""; echo "${COLOR_SECTION}━━━ $* ━━━${COLOR_RESET}"; }

echo ""
echo ""
$DRY_RUN && echo "🔍 DRY-RUN MODE — no changes will be made"
echo "🚀 Starting Mac Dev Bootstrap..."

# =============================================================================
# XCODE CLI TOOLS
# =============================================================================
section "Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  run xcode-select --install
  warn "Re-run this script after CLI tools install finishes."
  exit 1
else
  success "Xcode CLT already installed"
fi

# =============================================================================
# HOMEBREW
# =============================================================================
section "Homebrew"
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for Apple Silicon immediately after install
  # so subsequent brew commands in THIS script work without a shell restart
  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  success "Homebrew already installed ($(brew --version | head -1))"
fi

# =============================================================================
# BOOTSTRAP
# =============================================================================
BOOTSTRAP="$HOME/Developer/mac-bootstrap"
export ZDOTDIR="$BOOTSTRAP/zsh"
if [[ -f "$BOOTSTRAP/zsh/.zshenv" ]]; then
  source "$BOOTSTRAP/zsh/.zshenv"
fi

section "mac-bootstrap"

# Guard: mac-bootstrap repo must exist before we try to symlink from it
if [[ ! -d "$BOOTSTRAP" ]]; then
  warn "mac-bootstrap directory not found at $BOOTSTRAP — skipping symlinks"
  warn "Clone your mac-bootstrap repo there first, then re-run."
else
  info "Linking mac-bootstrap configs from $BOOTSTRAP..."
  run ln -sf "$BOOTSTRAP/zsh/.zshenv"            $HOME/.zshenv
  run ln -sf "$BOOTSTRAP/zsh/.zshrc"             $HOME/.zshrc
  run ln -sf "$BOOTSTRAP/zsh/.zprofile"          $HOME/.zprofile
  run ln -sf "$BOOTSTRAP/git/.gitconfig"         $HOME/.gitconfig
  run ln -sf "$BOOTSTRAP/git/.gitignore_global"  $HOME/.gitignore_global
  run ln -sf "$BOOTSTRAP/nvm/.nvmrc"             $HOME/.nvmrc
  success "mac-bootstrap configs linked"

  if $DRY_RUN; then
    echo "  [DRY-RUN] source ~/.zshrc"
  else
      setopt localoptions no_err_exit
      source ~/.zshrc
    success ".zshrc sourced"
  fi
fi

# =============================================================================
# BREW BUNDLE
# =============================================================================
section "Homebrew Bundle"

# Guard: Brewfile must exist in mac-bootstrap directory (or pass --file= path)
if [[ ! -f "$BOOTSTRAP/Brewfile" ]]; then
  warn "No Brewfile found in $BOOTSTRAP — skipping brew bundle"
  warn "Expected: $BOOTSTRAP/Brewfile"
else
  info "Installing from Brewfile..."
  run brew bundle --file "$BOOTSTRAP/Brewfile" --no-upgrade
  success "Brewfile packages installed"
fi

# =============================================================================
# JDK + JENV
# =============================================================================
section "JDK + jenv"

if ! command -v jenv &>/dev/null; then
  if [[ -d "$HOME/.jenv/bin" ]]; then
    if $DRY_RUN; then
      echo "  [DRY-RUN] export PATH=\"$HOME/.jenv/bin:$PATH\""
      echo "  [DRY-RUN] eval \"\$(jenv init -)\""
    else
      export PATH="$HOME/.jenv/bin:$PATH"
      eval "$(jenv init -)"
    fi
  fi
fi

if command -v jenv &>/dev/null; then
  success "jenv available"

  if command -v brew &>/dev/null && brew list --cask temurin@17 &>/dev/null; then
    JDK_17_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null)"
    if [[ -z "$JDK_17_HOME" ]]; then
      JDK_17_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"
    fi
    if [[ -d "$JDK_17_HOME" ]]; then
      info "Registering Temurin JDK 17 with jenv"
      run mkdir -p "$HOME/.jenv/versions"
      if $DRY_RUN; then
        echo "  [DRY-RUN] jenv add \"$JDK_17_HOME\""
        echo "  [DRY-RUN] jenv global <resolved-17-version>"
        success "jenv set to Temurin JDK 17"
      else
        jenv add "$JDK_17_HOME" >/dev/null
        JENV_VERSION="$(jenv versions --bare | grep -E '(^17$|^17\.|^temurin.*17)' | head -n 1)"
        if [[ -n "$JENV_VERSION" ]]; then
          jenv global "$JENV_VERSION"
          success "jenv set to Temurin JDK 17 ($JENV_VERSION)"
        else
          warn "jenv did not register a JDK 17 version"
        fi
      fi
    else
      warn "Temurin JDK 17 home not found at $JDK_17_HOME"
    fi
  else
    warn "Temurin JDK 17 not installed; ensure brew bundle ran successfully"
  fi
else
  warn "jenv not found; ensure it is installed via Brewfile, then re-run"
fi

# =============================================================================
# NVM + NODE
# =============================================================================
section "NVM + Node"

NVM_DIR="$HOME/.nvm"
export NVM_DIR
NVMRC_APPLIED=false

apply_nvmrc() {
  if [[ -f "$HOME/.nvmrc" ]]; then
    info "Installing Node version from ~/.nvmrc"
    run nvm install
    run nvm alias default "$(cat "$HOME/.nvmrc")"
    NVMRC_APPLIED=true
    return 0
  fi
  return 1
}

if command -v brew &>/dev/null && brew list node &>/dev/null; then
  info "Unlinking Homebrew Node to avoid PATH conflicts"
  run brew unlink node
fi

if ! command -v nvm &>/dev/null; then
  if ! $DRY_RUN && [[ -s "$(brew --prefix nvm)/nvm.sh" ]]; then
    source "$(brew --prefix nvm)/nvm.sh"
  fi
fi

if command -v nvm &>/dev/null; then
  success "NVM available"

  if apply_nvmrc; then
    success "Node version set from .nvmrc"
  else
    info "Installing Node LTS..."
    run nvm install --lts
    run nvm alias default lts/*
    success "Node LTS installed"
  fi
else
  warn "NVM not found; ensure it is installed via Brewfile, then re-run"
fi

if [[ "$NVMRC_APPLIED" != "true" ]]; then
  apply_nvmrc
fi

info "Ensuring global npm packages are installed (no upgrade)"
NPM_GLOBAL_PACKAGES=(typescript nodemon pnpm)
for pkg in "${NPM_GLOBAL_PACKAGES[@]}"; do
  if npm list -g --depth=0 "$pkg" &>/dev/null; then
    info "${pkg} already installed"
  else
    run npm install -g "$pkg"
  fi
done
success "Global npm packages ensured"

# =============================================================================
# SSH KEY
# =============================================================================
section "SSH Key"

if [[ -z "${GIT_EMAIL:-}" ]]; then
  if command -v git &>/dev/null; then
    GIT_EMAIL="$(git config --global user.email || true)"
  fi

  if [[ -n "${GIT_EMAIL:-}" ]]; then
    info "Using gitconfig email for SSH key: $GIT_EMAIL"
  fi

  if $DRY_RUN; then
    GIT_EMAIL="your@email.com"
    warn "DRY-RUN: using placeholder email '$GIT_EMAIL' for SSH key"
  else
    # zsh: read uses -r and '?' for the prompt (not -p like bash)
    if [[ -z "${GIT_EMAIL:-}" ]]; then
      read -r "GIT_EMAIL?  Enter your git email for SSH key: "
    fi
  fi
fi

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  info "Generating SSH key for $GIT_EMAIL..."
  run mkdir -p ~/.ssh
  run chmod 700 ~/.ssh
  run ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N ""
  run eval "$(ssh-agent -s)"
  run ssh-add --apple-use-keychain ~/.ssh/id_ed25519

  # Add to SSH config so key persists across reboots
  if ! $DRY_RUN; then
    if ! grep -q "id_ed25519" ~/.ssh/config 2>/dev/null; then
      cat >> ~/.ssh/config <<EOF

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
    fi
  else
    echo "  [DRY-RUN] write ~/.ssh/config Host block"
  fi

  success "SSH key generated. Add to GitHub with:"
  if ! $DRY_RUN; then
    echo ""
    echo "  If you want to add it to GitHub:"
    echo "  pbcopy < ~/.ssh/id_ed25519.pub"
    echo "  Then: https://github.com/settings/keys"
  else
    echo ""
    echo "  [DRY-RUN] If you want to add it to GitHub:"
    echo "  [DRY-RUN] pbcopy < ~/.ssh/id_ed25519.pub"
  fi
else
  success "SSH key already exists at ~/.ssh/id_ed25519"
  if ! $DRY_RUN; then
    echo ""
    echo "  If you want to add it to GitHub:"
    echo "  pbcopy < ~/.ssh/id_ed25519.pub"
    echo "  Then: https://github.com/settings/keys"
  else
    echo ""
    echo "  [DRY-RUN] If you want to add it to GitHub:"
    echo "  [DRY-RUN] pbcopy < ~/.ssh/id_ed25519.pub"
  fi
fi

# =============================================================================
# DONE
# =============================================================================
echo ""
success "🎉 Bootstrap complete! Restart your terminal (or open a new tab) to apply all changes."
if $DRY_RUN; then
  echo "   This was a dry-run. Re-run without --dry-run to apply changes."
fi