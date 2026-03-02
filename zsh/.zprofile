# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# NVM (Node Version Manager)
[ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && nvm use --silent