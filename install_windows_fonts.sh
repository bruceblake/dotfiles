#!/bin/bash

# Script to help install Nerd Fonts for WSL use in Windows Terminal

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== WSL NERD FONT INSTALLER =====${NC}"
echo "This script will help you install Nerd Fonts for use in Windows Terminal"

# Create a temporary directory for downloads
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Download the latest Meslo Nerd Font
echo -e "\n${YELLOW}Downloading MesloLGS Nerd Font...${NC}"
FONT_ZIP="$TEMP_DIR/Meslo.zip"
wget -q --show-progress -O "$FONT_ZIP" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip

if [ $? -ne 0 ]; then
  echo -e "${RED}Failed to download font. Please check your internet connection.${NC}"
  exit 1
fi

# Extract the fonts
echo -e "\n${YELLOW}Extracting fonts...${NC}"
mkdir -p "$TEMP_DIR/extracted"
unzip -q "$FONT_ZIP" -d "$TEMP_DIR/extracted"

# Find Windows username
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
WIN_HOME="/mnt/c/Users/$WIN_USER"

if [ ! -d "$WIN_HOME" ]; then
  echo -e "${RED}Could not find Windows home directory.${NC}"
  echo "Please manually copy the fonts from: $TEMP_DIR/extracted"
  echo "To your Windows Fonts folder or double-click each .ttf file to install"
  exit 1
fi

# Create a directory on the Windows side for the fonts
WIN_FONT_DIR="$WIN_HOME/Downloads/NerdFonts"
mkdir -p "$WIN_FONT_DIR"

# Copy the fonts to Windows
echo -e "\n${YELLOW}Copying fonts to Windows...${NC}"
cp "$TEMP_DIR/extracted"/*.ttf "$WIN_FONT_DIR"/

echo -e "\n${GREEN}Fonts are now in Windows at: $WIN_FONT_DIR${NC}"
echo -e "${YELLOW}INSTRUCTIONS:${NC}"
echo "1. Open Windows Explorer and navigate to: $WIN_FONT_DIR"
echo "2. Select all the .ttf files"
echo "3. Right-click and select 'Install' or 'Install for all users'"
echo "4. Open Windows Terminal"
echo "5. Go to Settings (Ctrl+,) -> Profile -> Appearance -> Font face"
echo "6. Select 'MesloLGS NF' from the dropdown"
echo "7. Click 'Save'"
echo "8. Restart your terminal"

# Cleanup
rm -rf "$TEMP_DIR"
echo -e "\n${GREEN}Installation complete! Temporary files cleaned up.${NC}"
