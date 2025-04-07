#!/bin/bash

# Ultimate reset script - removes all previous attempts and starts fresh

# Colors for feedback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== ULTIMATE RESET SCRIPT =====${NC}"
echo "This will completely reset everything related to Neovim/Vim and start fresh."
echo "All previous solutions will be removed."

# Ask for confirmation
read -p "Continue? This is destructive! (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# STEP 1: Kill any running editor processes
echo -e "\n${YELLOW}STEP 1: Killing any running editor processes...${NC}"
pkill -9 nvim vim 2>/dev/null || true
echo -e "${GREEN}Done.${NC}"

# STEP 2: Remove all custom scripts and editor installations
echo -e "\n${YELLOW}STEP 2: Removing all custom scripts and editor installations...${NC}"

# Remove all custom scripts
rm -f ~/my-nvim ~/bin/nvim ~/.local/bin/nvim ~/.local/bin/nvim.appimage 2>/dev/null || true
rm -rf ~/.local/bin/squashfs-root ~/standalone-nvim 2>/dev/null || true

# Remove editor configs
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim 2>/dev/null || true

# Remove all package manager installations
if command -v pacman &> /dev/null; then
    echo "Removing Neovim via pacman..."
    sudo pacman -Rns --noconfirm neovim 2>/dev/null || true
elif command -v apt &> /dev/null; then
    echo "Removing Neovim via apt..."
    sudo apt remove --purge -y neovim neovim-runtime 2>/dev/null || true
    sudo apt autoremove -y 2>/dev/null || true
elif command -v dnf &> /dev/null; then
    echo "Removing Neovim via dnf..."
    sudo dnf remove -y neovim 2>/dev/null || true
fi

echo -e "${GREEN}Done removing all editor installations.${NC}"

# STEP 3: Clean up .zshrc file
echo -e "\n${YELLOW}STEP 3: Cleaning up .zshrc file...${NC}"

# Back up .zshrc
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d%H%M%S)
echo "Created backup at ~/.zshrc.backup.$(date +%Y%m%d%H%M%S)"

# Remove all vim/nvim related lines from .zshrc
sed -i '/nvim/d' ~/.zshrc 2>/dev/null || true
sed -i '/EDITOR/d' ~/.zshrc 2>/dev/null || true
sed -i '/my-nvim/d' ~/.zshrc 2>/dev/null || true
sed -i '/standalone-nvim/d' ~/.zshrc 2>/dev/null || true

echo -e "${GREEN}Done cleaning .zshrc file.${NC}"

# STEP 4: Install a simple, reliable editor
echo -e "\n${YELLOW}STEP 4: Installing a simple, reliable editor...${NC}"

# Create directories
mkdir -p ~/bin

# Find the best editor available
EDITOR_FOUND=false

# Try to install Vim from package manager
if ! command -v vim &> /dev/null; then
    echo "Installing Vim..."
    if command -v pacman &> /dev/null; then
        sudo pacman -Sy
        sudo pacman -S --needed --noconfirm vim
        EDITOR_FOUND=true
    elif command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y vim
        EDITOR_FOUND=true
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y vim
        EDITOR_FOUND=true
    else
        echo -e "${RED}Could not detect package manager to install Vim.${NC}"
    fi
else
    EDITOR_FOUND=true
    echo "Vim is already installed."
fi

if [ "$EDITOR_FOUND" = false ]; then
    echo -e "${RED}Could not find or install an editor!${NC}"
    exit 1
fi

# STEP 5: Create a simple and reliable script
echo -e "\n${YELLOW}STEP 5: Creating a simple and reliable editor script...${NC}"

# Create a minimal script that calls vim
cat > ~/bin/nvim << 'EOF'
#!/bin/bash
# Simple script to run vim
if command -v vim &> /dev/null; then
    exec vim "$@"
else
    echo "ERROR: vim not found. Please install vim."
    exit 1
fi
EOF
chmod +x ~/bin/nvim

# Make sure ~/bin is in PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
echo 'export EDITOR="vim"' >> ~/.zshrc

echo -e "${GREEN}Editor script created at ~/bin/nvim${NC}"

# STEP 6: Set up the configuration
echo -e "\n${YELLOW}STEP 6: Setting up editor configuration...${NC}"

# Update the current PATH
export PATH="$HOME/bin:$PATH"

# Create symbolic link for Neovim config
if [ -d "$(pwd)/nvim" ]; then
    mkdir -p ~/.config
    rm -rf ~/.config/nvim 2>/dev/null || true
    ln -sf "$(pwd)/nvim" ~/.config/nvim
    echo -e "${GREEN}Linked Neovim configuration to ~/.config/nvim${NC}"
else
    echo -e "${RED}Neovim configuration directory not found in current directory!${NC}"
fi

# STEP 7: Final verification
echo -e "\n${YELLOW}STEP 7: Verifying installation...${NC}"

if [ -x ~/bin/nvim ]; then
    echo -e "${GREEN}Editor script exists and is executable.${NC}"
    
    # Test if it works
    if ~/bin/nvim --version > /dev/null 2>&1; then
        echo -e "${GREEN}Success! Editor is working.${NC}"
    else
        echo -e "${RED}Editor script exists but doesn't work.${NC}"
    fi
else
    echo -e "${RED}Editor script is missing or not executable!${NC}"
fi

# Final instructions
echo -e "\n${YELLOW}===== RESET COMPLETE =====${NC}"
echo "To start using the editor:"
echo "1. Close and reopen your terminal, or run: source ~/.zshrc"
echo "2. Run: nvim"
echo
echo "This will use Vim but with your Neovim configuration symlinked."
echo "If you have any issues, please report them."