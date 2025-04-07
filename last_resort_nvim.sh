#!/bin/bash

# This is a last resort script for getting Neovim working
# It uses the absolute simplest approach possible

echo "Last resort Neovim fix..."

# Check if system nvim is available and try to use it
if [ -f "/usr/bin/nvim" ]; then
    echo "Option 1: Using system nvim in /usr/bin"
    cp /usr/bin/nvim ~/my-nvim
    chmod +x ~/my-nvim
    ~/my-nvim --version && echo "Success with /usr/bin/nvim!"
elif [ -f "/usr/sbin/nvim" ]; then
    echo "Option 2: Using system nvim in /usr/sbin"
    cp /usr/sbin/nvim ~/my-nvim
    chmod +x ~/my-nvim
    ~/my-nvim --version && echo "Success with /usr/sbin/nvim!"
else
    echo "No system Neovim found, installing a minimal version"
    
    # Try to install via package manager
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y neovim
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y neovim
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm neovim
    else
        echo "Could not find a supported package manager"
    fi
    
    # Check if installation worked
    if command -v nvim &> /dev/null; then
        echo "Neovim installed successfully!"
        cp $(command -v nvim) ~/my-nvim
        chmod +x ~/my-nvim
    else
        echo "Package manager installation failed"
        
        # Last resort - use Vim
        if command -v vim &> /dev/null; then
            echo "Using Vim as a fallback"
            cat > ~/my-nvim << 'EOF'
#!/bin/bash
# Fallback to vim
exec vim "$@"
EOF
            chmod +x ~/my-nvim
            echo "Created a wrapper that uses Vim instead"
        else
            echo "ERROR: No editor found!"
            exit 1
        fi
    fi
fi

# Create the .config/nvim symlink
echo "Setting up Neovim configuration"
mkdir -p ~/.config
rm -rf ~/.config/nvim
ln -sf $(pwd)/nvim ~/.config/nvim

# Create an alias in the shell configuration
echo "Setting up Neovim alias"
echo "alias nvim='~/my-nvim'" >> ~/.zshrc

echo "Done! You can now use Neovim with:"
echo "1. ~/my-nvim"
echo "2. After restarting your terminal: nvim (via alias)"
echo 
echo "Run the following command to apply changes immediately:"
echo "source ~/.zshrc"