#!/usr/bin/env bash
set -e

DOTDIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== DOTFILES INSTALLER =====${NC}"
echo "This script will set up your development environment with:"
echo "- Neovim configuration"
echo "- tmux configuration"
echo "- zsh configuration"
echo "- git configuration"

# Check for required dependencies
echo -e "\n${YELLOW}Checking dependencies...${NC}"
missing_deps=()

# Check for Git
if ! command -v git &> /dev/null; then
    missing_deps+=("git")
fi

# Check for Stow
if ! command -v stow &> /dev/null; then
    missing_deps+=("stow")
fi

# Check for Neovim
if ! command -v nvim &> /dev/null; then
    missing_deps+=("neovim")
fi

# Check for tmux
if ! command -v tmux &> /dev/null; then
    missing_deps+=("tmux")
fi

# Check for zsh
if ! command -v zsh &> /dev/null; then
    missing_deps+=("zsh")
fi

# If dependencies are missing, inform user and exit
if [ ${#missing_deps[@]} -ne 0 ]; then
    echo -e "${RED}Missing dependencies:${NC}"
    for dep in "${missing_deps[@]}"; do
        echo "- $dep"
    done
    
    echo -e "\n${YELLOW}Please install the missing dependencies before proceeding.${NC}"
    echo "On Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
    echo "On Fedora/RHEL: sudo dnf install ${missing_deps[*]}"
    echo "On Arch Linux: sudo pacman -S ${missing_deps[*]}"
    echo "On macOS with Homebrew: brew install ${missing_deps[*]}"
    
    read -p "Do you want to continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create necessary directories
echo -e "\n${YELLOW}Creating necessary directories...${NC}"
mkdir -p "$CONFIG_DIR"
mkdir -p "$HOME/.local/share/fonts"
mkdir -p "$HOME/.cache/zsh"
mkdir -p "$HOME/.tmux/plugins"
echo -e "${GREEN}Directories created${NC}"

# Run bootstrap script to create symlinks
echo -e "\n${YELLOW}Bootstrapping dotfiles...${NC}"
bash "$DOTDIR/bootstrap.sh"

# Install tmux plugin manager if it doesn't exist
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "\n${YELLOW}Installing tmux plugin manager...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo -e "${GREEN}tmux plugin manager installed${NC}"
fi

# Setup Oh My Zsh if it's not installed and user wants it
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "\n${YELLOW}Oh My Zsh not detected.${NC}"
    read -p "Do you want to install Oh My Zsh? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${GREEN}Oh My Zsh installed${NC}"
    fi
fi

# Setup fonts (optional)
echo -e "\n${YELLOW}Would you like to install Nerd Fonts for proper icon display?${NC}"
read -p "Install MesloLGS NF fonts? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing MesloLGS NF fonts...${NC}"
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    
    # Download fonts
    curl -fLo "$FONT_DIR/MesloLGS NF Regular.ttf" \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    curl -fLo "$FONT_DIR/MesloLGS NF Bold.ttf" \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    curl -fLo "$FONT_DIR/MesloLGS NF Italic.ttf" \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    curl -fLo "$FONT_DIR/MesloLGS NF Bold Italic.ttf" \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    
    # Reload font cache
    if command -v fc-cache &> /dev/null; then
        fc-cache -f -v
        echo -e "${GREEN}Font cache reloaded${NC}"
    else
        echo -e "${YELLOW}fontconfig not found. Please reload your font cache manually.${NC}"
    fi
    
    echo -e "${GREEN}Fonts installed${NC}"
    echo "Please configure your terminal to use 'MesloLGS NF' font for best experience."
fi

# Check if we're in WSL and offer to install Windows fonts
if grep -q Microsoft /proc/version; then
    echo -e "\n${YELLOW}Windows Subsystem for Linux (WSL) detected.${NC}"
    read -p "Do you want to install fonts for Windows too? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installing fonts for Windows...${NC}"
        bash "$DOTDIR/install_windows_fonts.sh"
    fi
fi

# Make sure .zshenv is sourced
echo -e "\n${YELLOW}Setting up shell environment...${NC}"
if [ -f "$HOME/.zshenv" ]; then
    source "$HOME/.zshenv"
    echo -e "${GREEN}Shell environment configured${NC}"
else
    echo -e "${RED}Warning: .zshenv not found. Shell environment may not be configured correctly.${NC}"
fi

echo -e "\n${GREEN}✅ Installation complete!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Restart your terminal or run 'source ~/.zshenv'"
echo "2. Change your default shell to zsh: chsh -s $(which zsh)"
echo "3. For tmux, press Ctrl+Space followed by 'I' to install plugins"
echo "4. For Neovim, simply open it to install plugins automatically"
echo "5. Review and customize ~/.config/zsh/.private-env.sh for your environment"
echo
echo -e "${GREEN}Enjoy your new development environment!${NC}"