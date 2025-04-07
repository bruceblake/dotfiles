#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== INSTALLING REAL NEOVIM =====${NC}"
echo "This script will install the actual Neovim editor (not a Vim wrapper)."

# Step 1: Remove any existing wrapper scripts
echo -e "\n${YELLOW}Step 1: Removing any existing wrappers...${NC}"
rm -f ~/bin/nvim 2>/dev/null || true
rm -f ~/.local/bin/nvim 2>/dev/null || true
echo -e "${GREEN}Done.${NC}"

# Step 2: Install Neovim
echo -e "\n${YELLOW}Step 2: Installing Neovim...${NC}"

if command -v pacman &> /dev/null; then
    # Arch Linux
    echo "Using pacman on Arch Linux..."
    sudo pacman -Sy
    sudo pacman -S --needed --noconfirm neovim
    INSTALL_STATUS=$?
elif command -v apt &> /dev/null; then
    # Debian/Ubuntu
    echo "Using apt on Debian/Ubuntu..."
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo apt install -y neovim
    INSTALL_STATUS=$?
elif command -v dnf &> /dev/null; then
    # Fedora/RHEL
    echo "Using dnf on Fedora/RHEL..."
    sudo dnf install -y neovim
    INSTALL_STATUS=$?
else
    echo -e "${RED}Couldn't detect package manager.${NC}"
    INSTALL_STATUS=1
fi

# Check if installation was successful
if [ $INSTALL_STATUS -ne 0 ]; then
    echo -e "${RED}Failed to install Neovim with package manager.${NC}"
    exit 1
fi

# Step A: Check if nvim works now
if command -v nvim &> /dev/null; then
    NVIM_PATH=$(which nvim)
    echo -e "${GREEN}Neovim installed at: $NVIM_PATH${NC}"
    nvim --version | head -n 1
else
    echo -e "${RED}Neovim not found in PATH after installation!${NC}"
    exit 1
fi

# Step 3: Set up Neovim config
echo -e "\n${YELLOW}Step 3: Setting up Neovim configuration...${NC}"
mkdir -p ~/.config
rm -rf ~/.config/nvim 2>/dev/null || true

# Link to dotfiles nvim config
DOTFILES_DIR=$(pwd)
if [ -d "$DOTFILES_DIR/nvim" ]; then
    ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim
    echo -e "${GREEN}Linked Neovim configuration to ~/.config/nvim${NC}"
else
    echo -e "${RED}Neovim configuration directory not found in dotfiles!${NC}"
    exit 1
fi

# Step 4: Update .zshrc
echo -e "\n${YELLOW}Step 4: Updating .zshrc...${NC}"

# Remove any previous nvim aliases or settings
sed -i '/alias.*nvim/d' ~/.zshrc 2>/dev/null || true
sed -i '/EDITOR.*nvim/d' ~/.zshrc 2>/dev/null || true

# Add the proper EDITOR setting
echo 'export EDITOR="nvim"' >> ~/.zshrc

echo -e "${GREEN}Zsh configuration updated.${NC}"

# Final test
echo -e "\n${YELLOW}Testing Neovim...${NC}"
if nvim --headless -c 'quit' 2>/dev/null; then
    echo -e "${GREEN}Success! Neovim starts without errors.${NC}"
else
    echo -e "${YELLOW}Warning: Neovim had some startup issues. This might be due to plugins that need to be installed.${NC}"
    echo "Try running 'nvim' normally and wait for any plugin installations to complete."
fi

echo -e "\n${GREEN}===== INSTALLATION COMPLETE =====${NC}"
echo "To use Neovim:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Run: nvim"
echo
echo "If you have any plugin errors on first run, this is normal."
echo "Just wait for the plugins to install and then restart Neovim."