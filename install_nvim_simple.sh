#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Installing Neovim using package manager${NC}"

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

echo "Detected OS: $OS"

# Install Neovim
echo "Installing Neovim..."
case $OS in
  ubuntu|debian)
    sudo apt update
    sudo apt install -y neovim
    ;;
  fedora)
    sudo dnf install -y neovim
    ;;
  arch)
    sudo pacman -S --noconfirm neovim
    ;;
  macos)
    if command -v brew &> /dev/null; then
      brew install neovim
    else
      echo -e "${RED}Homebrew not found. Please install Homebrew first.${NC}"
      exit 1
    fi
    ;;
  *)
    echo -e "${RED}Unsupported OS: $OS${NC}"
    echo "Please install Neovim manually."
    exit 1
    ;;
esac

# Verify installation
if command -v nvim &> /dev/null; then
  echo -e "${GREEN}Neovim installed successfully!${NC}"
  nvim --version | head -n 1
else
  echo -e "${RED}Failed to install Neovim.${NC}"
  exit 1
fi

# Set up a script to find and use Neovim
echo "Setting up wrapper script..."
WRAPPER_DIR="$HOME/.local/bin"
mkdir -p "$WRAPPER_DIR"

cat > "$WRAPPER_DIR/nvim-wrapper" << 'EOF'
#!/bin/bash

# Try to find nvim in common locations
for nvim_path in /usr/bin/nvim /usr/local/bin/nvim /opt/homebrew/bin/nvim /snap/bin/nvim $(which nvim 2>/dev/null)
do
  if [ -x "$nvim_path" ]; then
    exec "$nvim_path" "$@"
    exit $?
  fi
done

# If we get here, we couldn't find nvim
echo "Error: Neovim not found in common locations."
echo "If you know where nvim is located, please add that directory to your PATH."

# Fall back to vim if available
if command -v vim &> /dev/null; then
  echo "Falling back to vim..."
  exec vim "$@"
  exit $?
fi

echo "Error: Neither nvim nor vim found. Please install one of them."
exit 1
EOF

chmod +x "$WRAPPER_DIR/nvim-wrapper"

# Add to PATH if not already there
if [[ ":$PATH:" != *":$WRAPPER_DIR:"* ]]; then
  echo "Adding $WRAPPER_DIR to PATH in .zshrc..."
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
  export PATH="$HOME/.local/bin:$PATH"
fi

# Create symlink to the wrapper
ln -sf "$WRAPPER_DIR/nvim-wrapper" "$WRAPPER_DIR/nvim"

echo -e "${GREEN}Installation complete!${NC}"
echo "The nvim wrapper script has been installed to: $WRAPPER_DIR/nvim"
echo -e "${YELLOW}You may need to restart your terminal or run 'source ~/.zshrc' for PATH changes to take effect.${NC}"
echo "To use Neovim, simply run: nvim"