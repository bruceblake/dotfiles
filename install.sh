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

# Check for and install Nerd Fonts
install_nerd_fonts() {
  echo -e "${YELLOW}Installing Nerd Fonts for proper icon rendering...${NC}"
  
  # Create fonts directory
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  
  # Download JetBrains Mono Nerd Font (popular and works well)
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf"
  FONT_FILE="JetBrains Mono Regular Nerd Font Complete.ttf"
  
  echo "Downloading JetBrains Mono Nerd Font..."
  if command -v curl &> /dev/null; then
    curl -fLo "$FONT_DIR/$FONT_FILE" "$FONT_URL"
  elif command -v wget &> /dev/null; then
    wget -O "$FONT_DIR/$FONT_FILE" "$FONT_URL"
  else
    echo -e "${RED}Neither curl nor wget is installed. Cannot download font.${NC}"
    return 1
  fi
  
  # Refresh font cache if fc-cache exists
  if command -v fc-cache &> /dev/null; then
    echo "Refreshing font cache with fc-cache..."
    fc-cache -fv
  else
    echo -e "${YELLOW}fc-cache not found. Font cache not refreshed.${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "On macOS, fonts should be available after installation without cache refresh."
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
      echo "On Windows, you may need to install the font manually."
    else
      echo "You may need to restart your session for fonts to be recognized."
    fi
  fi
  
  echo -e "${GREEN}Nerd Font installed.${NC}"
  echo -e "${YELLOW}IMPORTANT: You must configure your terminal to use this font!${NC}"
  echo "- For Windows Terminal: Settings → Profiles → Appearance → Font face → 'JetBrains Mono NF'"
  echo "- For iTerm2: Preferences → Profiles → Text → Font → 'JetBrains Mono Nerd Font'"
  echo "- For GNOME Terminal: Preferences → Profile → Custom font → 'JetBrains Mono Nerd Font'"
  echo "- For VS Code: Settings → Terminal › Integrated: Font Family → 'JetBrains Mono Nerd Font'"
  
  return 0
}

echo -e "${YELLOW}Nerd Fonts are required for proper icon rendering.${NC}"
read -p "Would you like to install JetBrains Mono Nerd Font? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  install_nerd_fonts
else
  echo -e "${YELLOW}Skipping Nerd Font installation. Icons may not display correctly.${NC}"
  echo "You can install them manually from https://www.nerdfonts.com/font-downloads"
fi

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

# Final instructions
cat << EOL

${YELLOW}=== Next Steps ===${NC}

1. ${GREEN}Configure your terminal to use the Nerd Font${NC}
   * Windows Terminal: Settings → Profiles → Appearance → Font face → 'JetBrains Mono NF'
   * iTerm2: Preferences → Profiles → Text → Font → 'JetBrains Mono Nerd Font'
   * GNOME Terminal: Preferences → Profile → Custom font → 'JetBrains Mono Nerd Font'
   * VSCode: Settings → Terminal › Integrated: Font Family → 'JetBrains Mono Nerd Font'

2. ${GREEN}Start a new tmux session${NC}
   * Run: ${YELLOW}tmux${NC}
   * Install plugins: Press ${YELLOW}Ctrl+Space${NC} then ${YELLOW}I${NC} (capital i)
   * Wait for plugins to install (you'll see a success message)

3. ${GREEN}Start Neovim${NC}
   * Run: ${YELLOW}nvim${NC}
   * Plugins will install automatically on first run

4. ${GREEN}Apply shell changes${NC}
   * Run: ${YELLOW}source ~/.zshrc${NC}
   * Or restart your terminal

${YELLOW}=== Troubleshooting ===${NC}

* If Nerd Fonts aren't displaying correctly:
  Run: ${YELLOW}./install_nerd_font.sh${NC}

* If Neovim isn't working properly:
  Run: ${YELLOW}./nvim_fix.sh${NC}
  
* If Neovim still won't start or isn't found:
  Run: ${YELLOW}./install_nvim_simple.sh${NC} (installs Neovim via package manager and creates a wrapper script)
  
* If the AppImage version doesn't work:
  Run: ${YELLOW}./install_nvim_appimage.sh${NC} (downloads and installs the latest AppImage version)

* If tmux doesn't look right:
  Make sure you have installed plugins with ${YELLOW}Ctrl+Space${NC} then ${YELLOW}I${NC}

${YELLOW}Enjoy your new environment!${NC}
EOL