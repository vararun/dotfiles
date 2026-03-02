# =============================================================================
# ALIAS DEFINITIONS
# =============================================================================

# git aliases
alias gs="git status"
alias gp="git pull"
alias gc="git commit -m"
alias gb="git branch"
alias ga="git add -A"
alias gp="git push"
alias gpf="git push --force"
alias gr="git reset"
alias gac="git add -A && git commit -m"

# general aliases
alias dev="cd ~/Developer"
alias mb="cd ~/Developer/mac-bootstrap"

# zsh aliases
alias zshconfig="code ~/.zshrc"
alias zshenv="code ~/.zshenv"
alias zprofile="code ~/.zprofile"
alias sourcezsh="source ~/.zshrc"

# script aliases
alias bootstrap="$HOME/Developer/mac-bootstrap/scripts/bootstrap.sh"

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

# Editor
export EDITOR="code"

# History
export HISTFILE="$HOME/.zsh_history"

# Developer folders
export DEV="$HOME/Developer"

# NVM
export NVM_DIR="$HOME/.nvm"

# Homebrew bundle
export HOMEBREW_BUNDLE_FILE="$HOME/Developer/mac-bootstrap/Brewfile"

# Path cleanup
export PATH="$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
	*":$PNPM_HOME:"*) ;;
	*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# =============================================================================
# ADDITIONAL CONFIGURATION, VS CODE INTEGRATION
# =============================================================================

# Prompt (minimal clean)
PROMPT='%1~ %# '

# NVM
[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"

# VS Code shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
