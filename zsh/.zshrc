# Load modular files
source $ZDOTDIR/exports.zsh
source $ZDOTDIR/aliases.zsh

# Prompt (minimal clean)
PROMPT='%1~ %# '

cd ~/Developer
# pnpm
export PNPM_HOME="/Users/avarghese/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
