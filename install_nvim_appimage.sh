#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Installing Neovim AppImage${NC}"
echo "This script will download and install the latest Neovim AppImage"

# Create local bin directory
NVIM_DIR="$HOME/.local/bin"
mkdir -p "$NVIM_DIR"

# Remove any existing nvim in local bin
if [ -f "$NVIM_DIR/nvim" ]; then
  echo "Removing existing nvim from $NVIM_DIR..."
  rm -f "$NVIM_DIR/nvim"
fi

# Download latest AppImage
echo "Downloading latest Neovim AppImage..."
if command -v curl &> /dev/null; then
  curl -L -o "$NVIM_DIR/nvim" https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
elif command -v wget &> /dev/null; then
  wget -O "$NVIM_DIR/nvim" https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
else
  echo -e "${RED}Neither curl nor wget is installed. Cannot download Neovim.${NC}"
  echo "Please install curl or wget and try again."
  exit 1
fi

# Make it executable
echo "Making nvim executable..."
chmod +x "$NVIM_DIR/nvim"

# Add to PATH if not already there
if [[ ":$PATH:" != *":$NVIM_DIR:"* ]]; then
  echo "Adding $NVIM_DIR to PATH in .zshrc..."
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
  export PATH="$HOME/.local/bin:$PATH"
fi

# Test if it works
echo "Testing Neovim installation..."
if "$NVIM_DIR/nvim" --version > /dev/null 2>&1; then
  NVIM_VERSION=$("$NVIM_DIR/nvim" --version | head -n 1)
  echo -e "${GREEN}Neovim AppImage installed successfully!${NC}"
  echo "Version: $NVIM_VERSION"
  echo "Location: $NVIM_DIR/nvim"
  echo -e "${YELLOW}You may need to restart your terminal or run 'source ~/.zshrc' for PATH changes to take effect.${NC}"
else
  echo -e "${RED}Failed to install Neovim AppImage.${NC}"
  echo "Try running the following command manually:"
  echo "  $NVIM_DIR/nvim --version"
fi

# Add vim as fallback
echo "Setting up Vim as fallback editor..."
echo 'if command -v nvim &>/dev/null; then alias vi="nvim"; alias vim="nvim"; else alias vi="vim"; fi' >> "$HOME/.zshrc"

echo -e "${GREEN}Installation complete!${NC}"
echo "To use Neovim, run: nvim"