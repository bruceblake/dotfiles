#!/bin/bash

# This script installs Vim and makes it available as both vim and nvim

echo "Setting up Vim as a replacement for Neovim..."

# Install Vim if not present
if ! command -v vim &> /dev/null; then
    echo "Installing Vim..."
    if command -v pacman &> /dev/null; then
        sudo pacman -Sy
        sudo pacman -S --needed --noconfirm vim
    elif command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y vim
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y vim
    else
        echo "ERROR: Could not detect package manager. Please install Vim manually."
        exit 1
    fi
fi

# Make a simple script that calls vim
echo "Creating nvim alias script..."
mkdir -p ~/bin
cat > ~/bin/nvim << 'EOF'
#!/bin/bash
exec vim "$@"
EOF
chmod +x ~/bin/nvim

# Add to PATH and make available
echo "Setting up alias and PATH..."
if ! grep -q "export PATH=\"\$HOME/bin:\$PATH\"" ~/.zshrc; then
    echo "export PATH=\"\$HOME/bin:\$PATH\"" >> ~/.zshrc
fi

echo "Setup complete! Now you can use 'vim' or 'nvim' and both will work."
echo "Restart your terminal or run 'source ~/.zshrc' to apply changes."