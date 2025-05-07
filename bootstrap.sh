#!/usr/bin/env bash
set -e

DOTDIR="$HOME/.dotfiles"

# 1. Link everything under config/ into ~/.config
stow -R --dir="$DOTDIR" --target="$HOME/.config" config

# 2. (optional) classic dotfiles directly in $HOME
# stow -R --dir="$DOTDIR" --target="$HOME" home

# 3. (optional) scripts into ~/bin
# mkdir -p "$HOME/bin"
# stow -R --dir="$DOTDIR" --target="$HOME/bin" bin

echo "✅  Dotfiles linked.  Open a new terminal and enjoy!"
