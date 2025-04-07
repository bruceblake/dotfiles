#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Neovim Diagnostic and Fix Tool${NC}"

# Check if nvim exists
if ! command -v nvim &> /dev/null; then
  echo -e "${RED}Neovim is not installed or not in PATH.${NC}"
  
  # Check common installation paths
  for path in /usr/bin/nvim /usr/local/bin/nvim /opt/homebrew/bin/nvim /snap/bin/nvim; do
    if [ -f "$path" ]; then
      echo -e "${GREEN}Found Neovim at: $path${NC}"
      echo "Creating a symbolic link to make it accessible in PATH"
      sudo ln -sf "$path" /usr/local/bin/nvim
      echo "Link created. Try using nvim now."
      exit 0
    fi
  done
  
  echo -e "${YELLOW}No Neovim installation found. Would you like to install it? (y/n)${NC}"
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Detect OS
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      OS=$ID
    elif [ -f /etc/debian_version ]; then
      OS=debian
    elif [ -f /etc/fedora-release ]; then
      OS=fedora
    elif [ -f /etc/arch-release ]; then
      OS=arch
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      OS=macos
    else
      OS=unknown
    fi
    
    case $OS in
      ubuntu|debian)
        echo "Installing Neovim on Ubuntu/Debian..."
        sudo apt update
        sudo apt install -y neovim
        ;;
      fedora)
        echo "Installing Neovim on Fedora..."
        sudo dnf install -y neovim
        ;;
      arch)
        echo "Installing Neovim on Arch Linux..."
        sudo pacman -S neovim
        ;;
      macos)
        echo "Installing Neovim on macOS with Homebrew..."
        if command -v brew &> /dev/null; then
          brew install neovim
        else
          echo -e "${RED}Homebrew not found. Please install Homebrew first.${NC}"
          echo "Visit https://brew.sh for installation instructions."
          exit 1
        fi
        ;;
      *)
        echo -e "${RED}Unsupported OS. Please install Neovim manually.${NC}"
        echo "Visit https://github.com/neovim/neovim/wiki/Installing-Neovim for instructions."
        exit 1
        ;;
    esac
    
    if command -v nvim &> /dev/null; then
      echo -e "${GREEN}Neovim installed successfully!${NC}"
    else
      echo -e "${RED}Failed to install Neovim. Please install it manually.${NC}"
      exit 1
    fi
  else
    echo "Skipping Neovim installation."
    exit 1
  fi
fi

# If we're here, nvim is installed
echo -e "${GREEN}Neovim is installed.${NC}"
NVIM_VERSION=$(nvim --version | head -n 1)
echo "Version: $NVIM_VERSION"

# Check for any startup errors
echo "Testing Neovim minimal startup..."
NVIM_ERROR=$(nvim --headless -c 'quit' 2>&1 || echo "Error detected")
if [[ "$NVIM_ERROR" == *"Error"* ]]; then
  echo -e "${RED}Neovim encountered an error during startup:${NC}"
  echo "$NVIM_ERROR"
  
  echo -e "${YELLOW}Trying to fix common issues...${NC}"
  
  # Check if ~/.config/nvim exists and is a symlink pointing to a non-existent location
  if [ -L "$HOME/.config/nvim" ] && [ ! -e "$HOME/.config/nvim" ]; then
    echo "Broken nvim symlink detected. Removing it..."
    rm "$HOME/.config/nvim"
    echo "Recreating symlink..."
    ln -sf "$(pwd)/nvim" "$HOME/.config/nvim"
  fi
  
  # Check for plugin issues
  if [ -d "$HOME/.local/share/nvim" ]; then
    echo "Would you like to reset your Neovim plugins? This may help if plugins are causing issues. (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak.$(date +%Y%m%d%H%M%S)"
      echo "Plugins backed up. They will be reinstalled on next Neovim start."
    fi
  fi
  
  echo -e "${YELLOW}Trying to start Neovim in minimal mode...${NC}"
  echo "Run the following command to test:"
  echo "  nvim --clean"
else
  echo -e "${GREEN}Neovim starts without errors.${NC}"
fi

echo -e "${YELLOW}Checking for nvim configuration...${NC}"
if [ -d "$HOME/.config/nvim" ]; then
  echo -e "${GREEN}Neovim configuration directory exists.${NC}"
  if [ -L "$HOME/.config/nvim" ]; then
    echo "It's a symlink pointing to: $(readlink -f "$HOME/.config/nvim")"
  else
    echo "It's a regular directory."
  fi
else
  echo -e "${RED}Neovim configuration directory not found.${NC}"
  echo "Creating symlink from dotfiles..."
  mkdir -p "$HOME/.config"
  ln -sf "$(pwd)/nvim" "$HOME/.config/nvim"
  echo "Symlink created."
fi

echo -e "${GREEN}Diagnostics complete.${NC}"
echo "If you're still having issues, try:"
echo "1. Start nvim with '--clean' flag to bypass plugins: nvim --clean"
echo "2. Check the health of your Neovim: nvim '+checkhealth'"
echo "3. Reset your config by moving ~/.config/nvim to a backup location"