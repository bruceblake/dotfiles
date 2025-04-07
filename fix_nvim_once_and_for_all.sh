#!/bin/bash

# Colors for readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}  NEOVIM COMPLETE REINSTALLATION SCRIPT           ${NC}"
echo -e "${BLUE}==================================================${NC}"
echo
echo -e "${YELLOW}This script will:${NC}"
echo "1. Remove ALL existing Neovim installations"
echo "2. Clean up paths, configs, and plugins"
echo "3. Install a fresh, working Neovim"
echo "4. Set up your dotfiles configuration"
echo

# Ask for confirmation
read -p "This is a destructive operation. Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation canceled."
    exit 1
fi

# Step 1: Aggressively remove existing Neovim installations
echo -e "\n${YELLOW}Step 1: Removing all existing Neovim installations...${NC}"

# Kill any running nvim processes
echo "Killing any running nvim processes..."
pkill -9 nvim 2>/dev/null || true

# Remove from package manager
echo "Removing Neovim from package manager..."
if command -v pacman &> /dev/null; then
    echo "Arch Linux detected, using pacman..."
    sudo pacman -Rns --noconfirm neovim 2>/dev/null || true
elif command -v apt &> /dev/null; then
    echo "Debian/Ubuntu detected, using apt..."
    sudo apt remove --purge -y neovim neovim-runtime 2>/dev/null || true
    sudo apt autoremove -y 2>/dev/null || true
elif command -v dnf &> /dev/null; then
    echo "Fedora/RHEL detected, using dnf..."
    sudo dnf remove -y neovim 2>/dev/null || true
fi

# Remove all possible nvim binaries
echo "Removing all possible nvim binaries..."
sudo rm -f /usr/bin/nvim /usr/local/bin/nvim /usr/sbin/nvim /bin/nvim /opt/*/bin/nvim 2>/dev/null || true
rm -f ~/.local/bin/nvim ~/bin/nvim ~/my-nvim 2>/dev/null || true

# Remove config and data directories
echo "Removing Neovim configuration and data directories..."
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim 2>/dev/null || true

# Remove AppImage installations
echo "Removing any AppImage installations..."
rm -rf ~/.local/bin/nvim.appimage ~/.local/bin/squashfs-root 2>/dev/null || true

# Clean up any build directories
echo "Cleaning up build directories..."
rm -rf ~/.neovim_build 2>/dev/null || true

echo -e "${GREEN}Done removing Neovim.${NC}"

# Step 2: Clean PATH entries
echo -e "\n${YELLOW}Step 2: Cleaning PATH entries...${NC}"

# Back up .zshrc before modifying it
cp ~/.zshrc ~/.zshrc.bak.$(date +%Y%m%d%H%M%S)
echo "Backed up .zshrc to ~/.zshrc.bak.$(date +%Y%m%d%H%M%S)"

# Remove nvim-related entries from .zshrc
sed -i '/nvim/d' ~/.zshrc 2>/dev/null || true

# Make sure ~/.local/bin is in PATH
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    echo "Added ~/.local/bin to PATH in .zshrc"
fi

# Create ~/.local/bin if it doesn't exist
mkdir -p ~/.local/bin

echo -e "${GREEN}PATH cleaned.${NC}"

# Step 3: Install Neovim
echo -e "\n${YELLOW}Step 3: Installing Neovim...${NC}"

# Try to detect OS
if command -v pacman &> /dev/null; then
    # Arch Linux
    echo "Using pacman on Arch Linux..."
    sudo pacman -Sy
    sudo pacman -S --needed --noconfirm neovim
    INSTALL_STATUS=$?
elif command -v apt &> /dev/null; then
    # Debian/Ubuntu
    echo "Using apt on Debian/Ubuntu..."
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

# Fall back to AppImage if package manager installation failed
if [ $INSTALL_STATUS -ne 0 ]; then
    echo "Package manager installation failed, trying AppImage..."
    
    # Install dependencies for AppImage
    if command -v pacman &> /dev/null; then
        sudo pacman -S --needed --noconfirm fuse2
    elif command -v apt &> /dev/null; then
        sudo apt install -y fuse libfuse2
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y fuse fuse-libs
    fi
    
    # Download AppImage
    if command -v curl &> /dev/null; then
        curl -L -o ~/.local/bin/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    elif command -v wget &> /dev/null; then
        wget -O ~/.local/bin/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    else
        echo -e "${RED}Neither curl nor wget found. Cannot download AppImage.${NC}"
        exit 1
    fi
    
    chmod +x ~/.local/bin/nvim.appimage
    
    # Create a symlink
    ln -sf ~/.local/bin/nvim.appimage ~/.local/bin/nvim
    
    # Test if AppImage works
    if ~/.local/bin/nvim --version > /dev/null 2>&1; then
        echo -e "${GREEN}AppImage installation successful.${NC}"
    else
        echo -e "${YELLOW}AppImage doesn't work directly, trying to extract it...${NC}"
        
        cd ~/.local/bin
        ./nvim.appimage --appimage-extract > /dev/null 2>&1
        
        if [ -d squashfs-root ]; then
            chmod +x squashfs-root/usr/bin/nvim
            ln -sf $(pwd)/squashfs-root/usr/bin/nvim ~/.local/bin/nvim
            
            if ~/.local/bin/nvim --version > /dev/null 2>&1; then
                echo -e "${GREEN}Extracted AppImage installation successful.${NC}"
            else
                echo -e "${RED}Extracted AppImage doesn't work. Using a simple wrapper script...${NC}"
                create_wrapper_script
            fi
        else
            echo -e "${RED}Failed to extract AppImage. Using a simple wrapper script...${NC}"
            create_wrapper_script
        fi
    fi
else
    echo -e "${GREEN}Package manager installation successful.${NC}"
fi

# Function to create a wrapper script as last resort
create_wrapper_script() {
    echo "Creating a simple wrapper script..."
    
    # Find nvim binary in standard locations
    NVIM_PATH=""
    for path in /usr/bin/nvim /usr/local/bin/nvim /usr/sbin/nvim; do
        if [ -x "$path" ]; then
            NVIM_PATH="$path"
            break
        fi
    done
    
    if [ -n "$NVIM_PATH" ]; then
        # Create wrapper that calls the actual binary
        cat > ~/.local/bin/nvim << EOF
#!/bin/bash
exec $NVIM_PATH "\$@"
EOF
        chmod +x ~/.local/bin/nvim
        echo "Created wrapper for $NVIM_PATH"
    else
        # If we can't find nvim, use vim as fallback
        cat > ~/.local/bin/nvim << 'EOF'
#!/bin/bash
if command -v vim &>/dev/null; then
    echo "Falling back to vim..."
    exec vim "$@"
else
    echo "ERROR: No editor found!"
    exit 1
fi
EOF
        chmod +x ~/.local/bin/nvim
        echo "Created fallback wrapper that uses vim"
    fi
}

# Step 4: Verify installation
echo -e "\n${YELLOW}Step 4: Verifying Neovim installation...${NC}"

# Set PATH for current session
export PATH="$HOME/.local/bin:$PATH"

if command -v nvim &> /dev/null; then
    # Get version info
    NVIM_VERSION=$(nvim --version | head -n 1)
    echo -e "${GREEN}Neovim is installed: $NVIM_VERSION${NC}"
    
    # Check which nvim is being executed
    NVIM_LOCATION=$(which nvim)
    echo "Location: $NVIM_LOCATION"
else
    echo -e "${RED}Neovim is not in PATH. Something went wrong.${NC}"
    exit 1
fi

# Step 5: Set up configuration
echo -e "\n${YELLOW}Step 5: Setting up Neovim configuration...${NC}"

# Get current directory
DOTFILES_DIR=$(pwd)

# Create symlink for Neovim config
if [ -d "$DOTFILES_DIR/nvim" ]; then
    echo "Setting up dotfiles Neovim configuration..."
    rm -rf ~/.config/nvim 2>/dev/null || true
    mkdir -p ~/.config
    ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim
    echo -e "${GREEN}Neovim configuration linked.${NC}"
else
    echo -e "${RED}Neovim configuration directory not found in dotfiles!${NC}"
    exit 1
fi

# Step 6: Final verification
echo -e "\n${YELLOW}Step 6: Final verification...${NC}"

# Try to run Neovim
echo "Testing Neovim..."
if nvim --headless -c 'quit' 2>/dev/null; then
    echo -e "${GREEN}Success! Neovim starts without errors.${NC}"
else
    echo -e "${RED}Neovim starts with errors. Trying to repair...${NC}"
    
    # Create a minimal init.lua for testing
    mkdir -p /tmp/minimal_nvim_config
    cat > /tmp/minimal_nvim_config/init.lua << 'EOF'
-- Minimal init.lua for testing
vim.o.compatible = false
vim.cmd('filetype plugin indent on')
vim.o.syntax = 'on'
EOF
    
    echo "Testing with minimal configuration..."
    if NVIM_APPNAME=minimal_nvim_config nvim --headless -c 'quit' 2>/dev/null; then
        echo -e "${YELLOW}Neovim works with minimal config. Your configuration might have issues.${NC}"
    else
        echo -e "${RED}Neovim fails even with minimal config. The installation has problems.${NC}"
        echo "Please manually run 'nvim --version' and check for errors."
    fi
fi

# Final instructions
echo -e "\n${BLUE}==================================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${BLUE}==================================================${NC}"
echo
echo "To use Neovim:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Run: nvim"
echo
echo "If Neovim doesn't start on first try, it might be installing plugins."
echo "Be patient and try again after a moment."
echo
echo "Your dotfiles Neovim configuration has been set up."
echo

# Clean up temp files
rm -rf /tmp/minimal_nvim_config 2>/dev/null || true