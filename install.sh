#!/bin/bash
# make executable with: chmod +x install.sh

DOTFILES="$HOME/Developer/dotfiles"

ln -sf $DOTFILES/zsh/.zshenv ~/.zshenv
ln -sf $DOTFILES/zsh/.zshrc ~/.zshrc
ln -sf $DOTFILES/zsh/.zprofile ~/.zprofile
ln -sf $DOTFILES/git/.gitconfig ~/.gitconfig
ln -sf $DOTFILES/git/.gitignore_global ~/.gitignore_global

echo "Dotfiles linked successfully."