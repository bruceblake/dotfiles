#!/bin/bash

# Improved installation script for tmux, nvim, and zsh

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== IMPROVED DOTFILES INSTALLER =====${NC}"
echo "This script will set up tmux, nvim, and zsh configurations"

# Create necessary directories following XDG spec
mkdir -p ~/.config/nvim
mkdir -p ~/.config/tmux
mkdir -p ~/.tmux/plugins
mkdir -p ~/.local/share/fonts
mkdir -p ~/.cache/zsh

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
# Create tmux.conf link in XDG location
ln -sf "${DOTFILES_DIR}/tmux/.tmux.conf" ~/.config/tmux/tmux.conf
# Create legacy symlink for compatibility
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf

if [ -d "${DOTFILES_DIR}/tmux/plugins/tpm" ]; then
  echo "Setting up tmux plugin manager..."
  mkdir -p ~/.tmux/plugins
  ln -sf "${DOTFILES_DIR}/tmux/plugins/tpm" ~/.tmux/plugins/
fi
echo -e "${GREEN}tmux configuration linked${NC}"

# Set up zsh
echo -e "\n${YELLOW}Setting up zsh...${NC}"
# Create/update .zshenv to follow XDG spec
cat > ~/.zshenv << 'EOL'
# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Source zshrc from XDG location
[ -f "$ZDOTDIR/.zshrc" ] && source "$ZDOTDIR/.zshrc"
EOL

# Create zsh config directory and link .zshrc
mkdir -p ~/.config/zsh
ln -sf "${DOTFILES_DIR}/zsh/.zshrc" ~/.config/zsh/.zshrc

# Legacy symlink for compatibility
ln -sf ~/.config/zsh/.zshrc ~/.zshrc

if [ -f "${DOTFILES_DIR}/zsh/private-env-example.sh" ]; then
  if [ ! -f "${HOME}/.config/zsh/.private-env.sh" ]; then
    echo "Creating private environment file..."
    cp "${DOTFILES_DIR}/zsh/private-env-example.sh" ~/.config/zsh/.private-env.sh
    chmod +x ~/.config/zsh/.private-env.sh
  fi
fi
echo -e "${GREEN}zsh configuration linked${NC}"

# Reload font cache
echo -e "\n${YELLOW}Setting up fonts...${NC}"
if command -v fc-cache &> /dev/null; then
    echo "Reloading font cache..."
    fc-cache -f -v
    echo -e "${GREEN}Font cache reloaded${NC}"
else
    echo -e "${RED}fontconfig not found. Please install it to reload font cache.${NC}"
    echo "On Ubuntu/Debian: sudo apt install fontconfig"
    echo "On Fedora/RHEL: sudo dnf install fontconfig"
    echo "On Arch Linux: sudo pacman -S fontconfig"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo "Notes:"
echo "1. For tmux, you may need to press Ctrl+Space followed by 'I' to install plugins"
echo "2. For Neovim, open it to let it install plugins automatically"
echo "3. If you're seeing icon issues in Neovim:"
echo "   - Make sure your terminal is using a Nerd Font (MesloLG Nerd Font recommended)"
echo "   - In your terminal settings, set font to 'MesloLGS NF' or similar"
echo "4. For zsh, you may need to restart your terminal or run 'source ~/.zshenv'"
echo "5. If your terminal supports it, enable True Color mode for best appearance"

# Create an update script
cat > ${DOTFILES_DIR}/update.sh << 'EOL'
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
EOL

chmod +x ${DOTFILES_DIR}/update.sh
echo -e "${GREEN}Created update.sh script for future updates${NC}"
