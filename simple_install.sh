#!/bin/bash

# Simple installation script for tmux, nvim, and zsh

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== SIMPLE DOTFILES INSTALLER =====${NC}"
echo "This script will set up tmux, nvim, and zsh configurations"

# Create necessary directories
mkdir -p ~/.config/nvim
mkdir -p ~/.config/tmux
mkdir -p ~/.tmux/plugins

# Get dotfiles directory
DOTFILES_DIR=$(pwd)

# Set up Neovim
echo -e "\n${YELLOW}Setting up Neovim...${NC}"
if [ -d "${HOME}/.config/nvim" ] && [ ! -L "${HOME}/.config/nvim" ]; then
  echo "Backing up existing nvim config..."
  mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d%H%M%S)
fi
ln -sf "${DOTFILES_DIR}/nvim" ~/.config/
echo -e "${GREEN}Neovim configuration linked${NC}"

# Set up tmux
echo -e "\n${YELLOW}Setting up tmux...${NC}"
ln -sf "${DOTFILES_DIR}/tmux/.tmux.conf" ~/.tmux.conf
if [ -d "${DOTFILES_DIR}/tmux/plugins/tpm" ]; then
  echo "Setting up tmux plugin manager..."
  mkdir -p ~/.tmux/plugins
  ln -sf "${DOTFILES_DIR}/tmux/plugins/tpm" ~/.tmux/plugins/
fi
echo -e "${GREEN}tmux configuration linked${NC}"

# Set up zsh
echo -e "\n${YELLOW}Setting up zsh...${NC}"
ln -sf "${DOTFILES_DIR}/zsh/.zshrc" ~/.zshrc
if [ -f "${DOTFILES_DIR}/zsh/private-env-example.sh" ]; then
  if [ ! -f "${HOME}/.private-env.sh" ]; then
    echo "Creating private environment file..."
    cp "${DOTFILES_DIR}/zsh/private-env-example.sh" ~/.private-env.sh
    chmod +x ~/.private-env.sh
  fi
fi
echo -e "${GREEN}zsh configuration linked${NC}"

echo -e "\n${GREEN}Installation complete!${NC}"
echo "Notes:"
echo "1. For tmux, you may need to press Ctrl+Space followed by 'I' to install plugins"
echo "2. For Neovim, you need to have Neovim installed on your system"
echo "   - On Arch Linux: sudo pacman -S neovim"
echo "   - On Ubuntu: sudo apt install neovim"
echo "3. You may need to restart your terminal or run 'source ~/.zshrc'"