#!/bin/bash

# This script sets up vim as the editor and creates a simple alias for nvim to vim

echo "Setting up vim as the primary editor..."

# Make sure vim is installed
if ! command -v vim &> /dev/null; then
    echo "Installing vim..."
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y vim
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y vim
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm vim
    else
        echo "Could not determine package manager. Please install vim manually."
        exit 1
    fi
fi

# Create a simple nvim script that just calls vim
SCRIPT_DIR="$HOME/.local/bin"
mkdir -p "$SCRIPT_DIR"

cat > "$SCRIPT_DIR/nvim" << 'EOF'
#!/bin/bash
# Simple wrapper that redirects nvim to vim
exec vim "$@"
EOF

chmod +x "$SCRIPT_DIR/nvim"

# Add to PATH if needed
if [[ ":$PATH:" != *":$SCRIPT_DIR:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    echo "Added $SCRIPT_DIR to PATH in .zshrc"
    export PATH="$HOME/.local/bin:$PATH"
fi

# Set EDITOR to vim
echo 'export EDITOR="vim"' >> "$HOME/.zshrc"

echo "Done! Now 'nvim' will run vim instead."
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."