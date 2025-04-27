#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== DOTFILES UPDATER =====${NC}"

# Update neovim plugins
echo -e "\n${YELLOW}Updating Neovim plugins...${NC}"
if command -v nvim &> /dev/null; then
    nvim --headless "+Lazy update" +qa
    echo -e "${GREEN}Neovim plugins updated${NC}"
else
    echo -e "${RED}Neovim not found. Cannot update plugins.${NC}"
fi

# Update tmux plugins
echo -e "\n${YELLOW}Updating tmux plugins...${NC}"
if [ -f "$HOME/.tmux/plugins/tpm/bin/update_plugins" ]; then
    $HOME/.tmux/plugins/tpm/bin/update_plugins all
    echo -e "${GREEN}tmux plugins updated${NC}"
else
    echo -e "${RED}tmux plugin manager not found. Cannot update plugins.${NC}"
fi

# Update Oh My Zsh
echo -e "\n${YELLOW}Updating Oh My Zsh...${NC}"
if [ -d "$HOME/.oh-my-zsh" ]; then
    $ZSH/tools/upgrade.sh
    echo -e "${GREEN}Oh My Zsh updated${NC}"
else
    echo -e "${RED}Oh My Zsh not found. Cannot update.${NC}"
fi

echo -e "\n${GREEN}Update complete!${NC}"
