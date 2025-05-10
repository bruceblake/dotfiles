#!/usr/bin/env bash
set -e

# Script to help install Nerd Fonts for WSL use in Windows Terminal

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== WSL NERD FONT INSTALLER =====${NC}"
echo "This script will help you install Nerd Fonts for use in Windows Terminal"

# Check if running on WSL
if ! grep -q Microsoft /proc/version; then
    echo -e "${RED}Error: This script is intended for Windows Subsystem for Linux (WSL) only.${NC}"
    exit 1
fi

# Check for required dependencies
echo -e "\n${YELLOW}Checking dependencies...${NC}"
missing_deps=()

# Check for curl or wget
if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    missing_deps+=("curl or wget")
fi

# Check for unzip
if ! command -v unzip &> /dev/null; then
    missing_deps+=("unzip")
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
    
    exit 1
fi

# Create a temporary directory for downloads
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Decide which method to use for downloading
download_method=""
if command -v curl &> /dev/null; then
    download_method="curl"
elif command -v wget &> /dev/null; then
    download_method="wget"
fi

# Download options
echo -e "\n${YELLOW}Select font installation method:${NC}"
echo "1) Install MesloLGS NF (recommended for PowerLevel10k theme)"
echo "2) Install full Meslo Nerd Font collection (more options, larger download)"
read -p "Select an option (1/2) [default: 1]: " -n 1 -r font_option
echo
font_option=${font_option:-1}

# Find Windows username
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
WIN_HOME="/mnt/c/Users/$WIN_USER"

if [ ! -d "$WIN_HOME" ]; then
    echo -e "${RED}Could not find Windows home directory.${NC}"
    echo "Will download fonts anyway and provide manual installation instructions."
    WIN_FONT_DIR="$TEMP_DIR/fonts_to_install"
else
    # Create a directory on the Windows side for the fonts
    WIN_FONT_DIR="$WIN_HOME/Downloads/NerdFonts"
fi

mkdir -p "$WIN_FONT_DIR"

if [ "$font_option" == "1" ]; then
    # Option 1: Download MesloLGS NF (PowerLevel10k)
    echo -e "\n${YELLOW}Downloading MesloLGS NF fonts...${NC}"
    
    FONT_FILES=(
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
    )
    
    for url in "${FONT_FILES[@]}"; do
        filename=$(basename "$url" | sed 's/%20/ /g')
        echo "Downloading $filename..."
        
        if [ "$download_method" == "curl" ]; then
            curl -fL --progress-bar "$url" -o "$TEMP_DIR/$filename"
        else
            wget -q --show-progress "$url" -O "$TEMP_DIR/$filename"
        fi
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to download font. Please check your internet connection.${NC}"
            exit 1
        fi
        
        cp "$TEMP_DIR/$filename" "$WIN_FONT_DIR/"
    done
    
    echo -e "${GREEN}MesloLGS NF fonts downloaded successfully!${NC}"
    
else
    # Option 2: Download full Meslo Nerd Font collection
    echo -e "\n${YELLOW}Downloading Meslo Nerd Font collection...${NC}"
    FONT_ZIP="$TEMP_DIR/Meslo.zip"
    
    if [ "$download_method" == "curl" ]; then
        curl -fL --progress-bar "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip" -o "$FONT_ZIP"
    else
        wget -q --show-progress "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip" -O "$FONT_ZIP"
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to download font. Please check your internet connection.${NC}"
        exit 1
    fi
    
    # Extract the fonts
    echo -e "\n${YELLOW}Extracting fonts...${NC}"
    mkdir -p "$TEMP_DIR/extracted"
    unzip -q "$FONT_ZIP" -d "$TEMP_DIR/extracted"
    
    # Copy the fonts to Windows
    echo -e "\n${YELLOW}Copying fonts to Windows...${NC}"
    cp "$TEMP_DIR/extracted"/*.ttf "$WIN_FONT_DIR"/
    
    echo -e "${GREEN}Meslo Nerd Font collection downloaded successfully!${NC}"
fi

echo -e "\n${GREEN}Fonts are now in Windows at: $WIN_FONT_DIR${NC}"
echo -e "${YELLOW}INSTALLATION INSTRUCTIONS:${NC}"
echo "1. Open Windows Explorer and navigate to: $WIN_FONT_DIR"
echo "2. Select all the .ttf files"
echo "3. Right-click and select 'Install' or 'Install for all users'"
echo "4. Configure Windows Terminal:"
echo "   - Open Windows Terminal"
echo "   - Go to Settings (Ctrl+,) -> Profile -> Appearance -> Font face"
echo "   - Select 'MesloLGS NF' from the dropdown"
echo "   - Click 'Save'"
echo "5. Restart your terminal"

# Attempt to automatically open the folder in Windows Explorer
if [ -d "$WIN_HOME" ]; then
    echo -e "\n${YELLOW}Attempting to open the font folder in Windows Explorer...${NC}"
    explorer.exe "$(wslpath -w "$WIN_FONT_DIR")" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Windows Explorer opened to the font folder.${NC}"
    else
        echo -e "${YELLOW}Could not open Windows Explorer automatically. Please navigate manually.${NC}"
    fi
fi

# Cleanup
rm -rf "$TEMP_DIR"
echo -e "\n${GREEN}✅ Installation complete! Temporary files cleaned up.${NC}"
