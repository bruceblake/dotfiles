#!/bin/bash

# This script specifically targets the issue where nvim is in /usr/sbin but not accessible

echo "Fixing Neovim in /usr/sbin..."

# Check if /usr/sbin/nvim exists
if [ -f "/usr/sbin/nvim" ]; then
    echo "Found nvim in /usr/sbin"
    
    # Check if it's executable
    if [ -x "/usr/sbin/nvim" ]; then
        echo "Nvim is executable"
    else
        echo "Making nvim executable..."
        sudo chmod +x /usr/sbin/nvim
    fi
    
    # Create a simple wrapper in ~/.local/bin
    echo "Creating wrapper script..."
    mkdir -p ~/.local/bin
    
    cat > ~/.local/bin/nvim << 'EOF'
#!/bin/bash
# Direct wrapper to /usr/sbin/nvim
exec /usr/sbin/nvim "$@"
EOF
    
    chmod +x ~/.local/bin/nvim
    
    # Make sure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo "Adding ~/.local/bin to PATH in .zshrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Test if it works
    echo "Testing wrapper..."
    ~/.local/bin/nvim --version
    
    if [ $? -eq 0 ]; then
        echo "Success! Neovim wrapper is working."
        echo "You can now use 'nvim' from anywhere."
        echo "Please restart your terminal or run: source ~/.zshrc"
    else
        echo "Wrapper test failed."
    fi
else
    echo "Error: /usr/sbin/nvim not found"
    echo "Please check if Neovim is installed at a different location."
fi