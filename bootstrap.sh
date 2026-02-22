set -e

echo "🚀 Starting Mac Dev Bootstrap..."

########################################
# Install Xcode CLI Tools
########################################
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "⚠️  Re-run this script after CLI tools install finishes."
  exit 1
fi

########################################
# Install Homebrew
########################################
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

########################################
# Setup simlinks for dotfiles, then source zshrc to apply changes
########################################

DOTFILES="$HOME/Developer/dotfiles"

ln -sf $DOTFILES/zsh/.zshenv ~/.zshenv
ln -sf $DOTFILES/zsh/.zshrc ~/.zshrc
ln -sf $DOTFILES/zsh/.zprofile ~/.zprofile
ln -sf $DOTFILES/git/.gitconfig ~/.gitconfig
ln -sf $DOTFILES/git/.gitignore_global ~/.gitignore_global

set +e
source ~/.zshrc
set -e

echo "Dotfiles linked successfully."

########################################
# Core Packages
########################################
echo "Installing core packages..."

brew bundle

echo "Core packages installed successfully."

########################################
# Setup NVM + Node
########################################
if ! command -v nvm &>/dev/null || [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "Setting up NVM (Node Version Manager)..."
    mkdir -p ~/.nvm
    npm install -g typescript nodemon pnpm
    echo "NVM and Node setup completed successfully."
fi

########################################
# Generate SSH Key (if missing)
########################################
if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -C "$gitemail"
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
  echo "🔑 Add this SSH key to GitHub:"
  cat ~/.ssh/id_ed25519.pub
fi

echo "🎉 Mac Dev Bootstrap completed successfully!"
echo "➡️  Restart your terminal to apply changes."