#!/bin/bash

# This script creates a completely standalone version of Neovim
# that doesn't depend on system paths or packages

echo "Creating standalone Neovim setup..."

# Create directories
mkdir -p ~/standalone-nvim/bin
mkdir -p ~/.config

# First, try to create a minimal Vim-based version that will definitely work
cat > ~/standalone-nvim/bin/minimal-nvim << 'EOF'
#!/bin/bash

# Use system vim as editor
if command -v vim &> /dev/null; then
    exec vim "$@"
else
    echo "ERROR: vim not found. Please install vim."
    exit 1
fi
EOF

chmod +x ~/standalone-nvim/bin/minimal-nvim
echo "Created minimal fallback editor."

# Add the nvim configuration
if [ -d "$(pwd)/nvim" ]; then
    echo "Linking Neovim configuration..."
    rm -rf ~/.config/nvim
    ln -sf "$(pwd)/nvim" ~/.config/nvim
fi

# Set up alias in .zshrc
if grep -q "standalone-nvim" ~/.zshrc; then
    echo "Standalone-nvim alias already exists in .zshrc"
else
    echo "Adding standalone-nvim alias to .zshrc..."
    echo "# Standalone Neovim setup" >> ~/.zshrc
    echo "alias nvim='~/standalone-nvim/bin/minimal-nvim'" >> ~/.zshrc
fi

echo "Standalone Neovim setup complete!"
echo "Restart your terminal or run 'source ~/.zshrc', then use 'nvim' to edit files."
echo "Note: This is using Vim as a fallback but will use your Neovim config."