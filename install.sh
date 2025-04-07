#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Installing dotfiles..."

# Check for required software
check_command() {
  if ! command -v $1 &> /dev/null; then
    echo -e "${RED}$1 is not installed. Please install it before continuing.${NC}"
    echo "You can typically install it with one of the following:"
    echo "  - Debian/Ubuntu: sudo apt install $1"
    echo "  - Fedora: sudo dnf install $1"
    echo "  - Arch Linux: sudo pacman -S $1"
    return 1
  else
    echo -e "${GREEN}$1 is installed.${NC}"
    return 0
  fi
}

# Check for required software
echo "Checking for required software..."
MISSING_SOFTWARE=0

check_command git || MISSING_SOFTWARE=1
check_command zsh || MISSING_SOFTWARE=1
check_command tmux || MISSING_SOFTWARE=1
check_command nvim || MISSING_SOFTWARE=1

# Check for Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${YELLOW}Oh My Zsh is not installed.${NC}"
  read -p "Would you like to install Oh My Zsh? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    echo -e "${RED}Oh My Zsh is required for the ZSH configuration.${NC}"
    MISSING_SOFTWARE=1
  fi
else
  echo -e "${GREEN}Oh My Zsh is installed.${NC}"
fi

# Check for Nerd Fonts
echo -e "${YELLOW}Note: Nerd Fonts are recommended for proper rendering of icons.${NC}"
echo "You can install them from https://www.nerdfonts.com/font-downloads"

if [ $MISSING_SOFTWARE -eq 1 ]; then
  echo -e "${RED}Some required software is missing. Please install the missing software and run the script again.${NC}"
  exit 1
fi

echo -e "${GREEN}All required software is installed. Continuing with installation...${NC}"

# Create directories if they don't exist
mkdir -p ${HOME}/.config
mkdir -p ${HOME}/.oh-my-zsh

# Create symlinks for shell configs
ln -sf $(pwd)/zsh/.zshrc ${HOME}/.zshrc
ln -sf $(pwd)/git/.gitconfig ${HOME}/.gitconfig
ln -sf $(pwd)/bash/.bashrc ${HOME}/.bashrc
ln -sf $(pwd)/bash/.bash_profile ${HOME}/.bash_profile

# Setup tmux with TPM
mkdir -p ${HOME}/.tmux/plugins
mkdir -p ${HOME}/.config/tmux

# Copy tmux configuration and TPM
cp -r $(pwd)/tmux/plugins/tpm ${HOME}/.tmux/plugins/
ln -sf $(pwd)/tmux/.tmux.conf ${HOME}/.config/tmux/tmux.conf
ln -sf $(pwd)/tmux/.tmux.conf ${HOME}/.tmux.conf

# Handle Neovim config
if [ -d "${HOME}/.config/nvim" ]; then
  echo -e "${YELLOW}Existing nvim configuration found. Backing it up...${NC}"
  mv ${HOME}/.config/nvim ${HOME}/.config/nvim.backup.$(date +%Y%m%d%H%M%S)
  echo -e "${GREEN}Backup created at ${HOME}/.config/nvim.backup.$(date +%Y%m%d%H%M%S)${NC}"
fi

# Create symlink for nvim config
ln -sf $(pwd)/nvim ${HOME}/.config/nvim

# Create private environment file if it doesn't exist
if [ ! -f "${HOME}/.private-env.sh" ]; then
  echo -e "${YELLOW}Creating example private environment file...${NC}"
  cp $(pwd)/zsh/private-env-example.sh ${HOME}/.private-env.sh
  chmod +x ${HOME}/.private-env.sh
  echo -e "${GREEN}Created ${HOME}/.private-env.sh - edit this file to add your API keys${NC}"
fi

echo -e "${GREEN}Dotfiles installed successfully!${NC}"
echo -e "${YELLOW}Note: You may need to restart your shell or run 'source ~/.zshrc' to apply changes.${NC}"