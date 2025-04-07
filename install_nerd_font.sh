#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Nerd Font Installer${NC}"
echo "This script will install a JetBrains Mono Nerd Font"

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
  echo "Please install curl or wget and try again."
  exit 1
fi

# Refresh font cache if fc-cache exists
if command -v fc-cache &> /dev/null; then
  echo "Refreshing font cache with fc-cache..."
  fc-cache -fv
else
  echo -e "${YELLOW}fc-cache not found. Font cache not refreshed.${NC}"
  
  # Platform-specific instructions
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "On macOS, the font should be available after installation without cache refresh."
  elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "On Windows:"
    echo "1. Open the folder: $FONT_DIR"
    echo "2. Right-click on the font file and select 'Install'"
  else
    echo "You may need to restart your session for fonts to be recognized."
  fi
fi

echo -e "${GREEN}Nerd Font downloaded to: $FONT_DIR/$FONT_FILE${NC}"
echo -e "${YELLOW}IMPORTANT: You must configure your terminal to use this font!${NC}"
echo "- For Windows Terminal: Settings → Profiles → Appearance → Font face → 'JetBrains Mono NF'"
echo "- For iTerm2: Preferences → Profiles → Text → Font → 'JetBrains Mono Nerd Font'"
echo "- For GNOME Terminal: Preferences → Profile → Custom font → 'JetBrains Mono Nerd Font'"
echo "- For VS Code: Settings → Terminal › Integrated: Font Family → 'JetBrains Mono Nerd Font'"