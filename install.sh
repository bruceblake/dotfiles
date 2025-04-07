#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Installing dotfiles..."

# Create directories if they don't exist
mkdir -p ${HOME}/.config
mkdir -p ${HOME}/.oh-my-zsh

# Create symlinks for shell configs
ln -sf $(pwd)/zsh/.zshrc ${HOME}/.zshrc
ln -sf $(pwd)/tmux/.tmux.conf ${HOME}/.tmux.conf
ln -sf $(pwd)/git/.gitconfig ${HOME}/.gitconfig
ln -sf $(pwd)/bash/.bashrc ${HOME}/.bashrc
ln -sf $(pwd)/bash/.bash_profile ${HOME}/.bash_profile

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