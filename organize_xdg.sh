#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== ORGANIZING DOTFILES FOLLOWING XDG STANDARD =====${NC}"
echo "This script will reorganize your dotfiles to follow the XDG Base Directory Specification."
echo "Most configuration files should live in ~/.config/"

# Step 1: Create proper directory structure
echo -e "\n${YELLOW}Step 1: Creating XDG directory structure...${NC}"
mkdir -p ~/.config/{zsh,git,tmux,bash,nvim}
echo -e "${GREEN}Done.${NC}"

# Step 2: Reorganize repository structure
echo -e "\n${YELLOW}Step 2: Reorganizing dotfiles repository...${NC}"

# Create config directory if it doesn't exist
mkdir -p "$(pwd)/config"

# Handle zsh configurations
echo "Moving zsh configurations..."
if [ -d "$(pwd)/zsh" ]; then
    mkdir -p "$(pwd)/config/zsh"
    cp "$(pwd)/zsh/.zshrc" "$(pwd)/config/zsh/zshrc"
    if [ -f "$(pwd)/zsh/private-env-example.sh" ]; then
        cp "$(pwd)/zsh/private-env-example.sh" "$(pwd)/config/zsh/private-env-example.sh"
    fi
fi

# Handle tmux configurations
echo "Moving tmux configurations..."
if [ -d "$(pwd)/tmux" ]; then
    mkdir -p "$(pwd)/config/tmux"
    cp "$(pwd)/tmux/.tmux.conf" "$(pwd)/config/tmux/tmux.conf"
    if [ -d "$(pwd)/tmux/plugins" ]; then
        cp -r "$(pwd)/tmux/plugins" "$(pwd)/config/tmux/"
    fi
fi

# Handle git configurations
echo "Moving git configurations..."
if [ -d "$(pwd)/git" ]; then
    mkdir -p "$(pwd)/config/git"
    cp "$(pwd)/git/.gitconfig" "$(pwd)/config/git/config"
fi

# Handle bash configurations
echo "Moving bash configurations..."
if [ -d "$(pwd)/bash" ]; then
    mkdir -p "$(pwd)/config/bash"
    cp "$(pwd)/bash/.bashrc" "$(pwd)/config/bash/bashrc"
    cp "$(pwd)/bash/.bash_profile" "$(pwd)/config/bash/bash_profile"
fi

# Handle nvim configurations
echo "Moving nvim configurations..."
if [ -d "$(pwd)/nvim" ]; then
    # Nvim is already in the right place
    cp -r "$(pwd)/nvim" "$(pwd)/config/"
fi

echo -e "${GREEN}Dotfiles reorganization complete.${NC}"

# Step 3: Update install script
echo -e "\n${YELLOW}Step 3: Creating new installation script...${NC}"

cat > "$(pwd)/xdg_install.sh" << 'EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== INSTALLING DOTFILES (XDG STYLE) =====${NC}"

# Create necessary directories
mkdir -p ~/.config/{zsh,git,tmux,bash,nvim}

# Get the dotfiles directory
DOTFILES_DIR=$(pwd)

# Link configurations
echo -e "\n${YELLOW}Linking configurations...${NC}"

# Zsh configuration
if [ -d "$DOTFILES_DIR/config/zsh" ]; then
    echo "Linking Zsh configuration..."
    ln -sf "$DOTFILES_DIR/config/zsh/zshrc" ~/.config/zsh/.zshrc
    
    # Create .zshenv in home to source the XDG config
    cat > ~/.zshenv << 'ZSHENV'
# Set XDG paths
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
ZSHENV
    
    # Create .zshrc in home to source the XDG config
    cat > ~/.zshrc << 'ZSHRC'
# Source XDG zsh config
[ -f "$HOME/.config/zsh/.zshrc" ] && source "$HOME/.config/zsh/.zshrc"
ZSHRC
    
    echo -e "${GREEN}✓ Zsh configuration linked${NC}"
fi

# Tmux configuration
if [ -d "$DOTFILES_DIR/config/tmux" ]; then
    echo "Linking Tmux configuration..."
    ln -sf "$DOTFILES_DIR/config/tmux/tmux.conf" ~/.config/tmux/tmux.conf
    
    # Also create a symlink for compatibility
    ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
    
    # Link plugins if they exist
    if [ -d "$DOTFILES_DIR/config/tmux/plugins" ]; then
        mkdir -p ~/.config/tmux/plugins
        ln -sf "$DOTFILES_DIR/config/tmux/plugins/tpm" ~/.config/tmux/plugins/tpm
        
        # For compatibility, also link to traditional location
        mkdir -p ~/.tmux/plugins
        ln -sf "$DOTFILES_DIR/config/tmux/plugins/tpm" ~/.tmux/plugins/tpm
    fi
    
    echo -e "${GREEN}✓ Tmux configuration linked${NC}"
fi

# Git configuration
if [ -d "$DOTFILES_DIR/config/git" ]; then
    echo "Linking Git configuration..."
    ln -sf "$DOTFILES_DIR/config/git/config" ~/.config/git/config
    
    # Also create a symlink for compatibility
    ln -sf ~/.config/git/config ~/.gitconfig
    
    echo -e "${GREEN}✓ Git configuration linked${NC}"
fi

# Bash configuration
if [ -d "$DOTFILES_DIR/config/bash" ]; then
    echo "Linking Bash configuration..."
    ln -sf "$DOTFILES_DIR/config/bash/bashrc" ~/.config/bash/bashrc
    ln -sf "$DOTFILES_DIR/config/bash/bash_profile" ~/.config/bash/bash_profile
    
    # Also create symlinks for compatibility
    ln -sf ~/.config/bash/bashrc ~/.bashrc
    ln -sf ~/.config/bash/bash_profile ~/.bash_profile
    
    echo -e "${GREEN}✓ Bash configuration linked${NC}"
fi

# Neovim configuration
if [ -d "$DOTFILES_DIR/config/nvim" ]; then
    echo "Linking Neovim configuration..."
    ln -sf "$DOTFILES_DIR/config/nvim" ~/.config/
    
    echo -e "${GREEN}✓ Neovim configuration linked${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo "Your dotfiles are now set up following the XDG Base Directory Specification."
echo "Notes:"
echo "1. For zsh, .zshenv and .zshrc in your home directory will source the XDG config."
echo "2. For compatibility, some symlinks to traditional locations were also created."
echo 
echo "You may need to restart your terminal or run 'source ~/.zshrc'."
EOF

chmod +x "$(pwd)/xdg_install.sh"
echo -e "${GREEN}New installation script created at $(pwd)/xdg_install.sh${NC}"

echo -e "\n${YELLOW}===== NEXT STEPS =====${NC}"
echo "1. Review the reorganized files in the 'config' directory"
echo "2. Commit the changes to your git repository"
echo "3. On your other machines, run 'xdg_install.sh' to set up the XDG-compliant configuration"
echo
echo "Note: The original files have not been removed, so your current setup will continue to work."