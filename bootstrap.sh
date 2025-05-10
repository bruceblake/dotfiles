#!/usr/bin/env bash
set -e

DOTDIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== DOTFILES BOOTSTRAP =====${NC}"
echo "This script will create symlinks for your dotfiles"

# Ensure ~/.config directory exists
mkdir -p "$CONFIG_DIR"

# 1. Link everything under config/ into ~/.config
echo -e "\n${YELLOW}Creating symlinks for config files...${NC}"
if command -v stow &> /dev/null; then
    stow -R --dir="$DOTDIR" --target="$CONFIG_DIR" config
    echo -e "${GREEN}Symlinks created for config files${NC}"
else
    echo -e "${RED}GNU Stow not found. Please install it first.${NC}"
    echo "On Ubuntu/Debian: sudo apt install stow"
    echo "On Fedora/RHEL: sudo dnf install stow"
    echo "On Arch Linux: sudo pacman -S stow"
    echo "On macOS with Homebrew: brew install stow"
    exit 1
fi

# 2. Create ~/.zshenv to point to XDG config
echo -e "\n${YELLOW}Setting up zsh environment...${NC}"
if [ -f "$HOME/.zshenv" ]; then
    echo "Backing up existing .zshenv..."
    mv "$HOME/.zshenv" "$HOME/.zshenv.backup.$(date +%Y%m%d%H%M%S)"
fi

cat > "$HOME/.zshenv" << 'EOL'
# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Source zshrc from XDG location
[ -f "$ZDOTDIR/.zshrc" ] && source "$ZDOTDIR/.zshrc"
EOL

echo -e "${GREEN}Created .zshenv file${NC}"

# 3. Create private environment file if it doesn't exist
if [ -f "$DOTDIR/config/zsh/private-env-example.sh" ] && [ ! -f "$CONFIG_DIR/zsh/.private-env.sh" ]; then
    echo -e "\n${YELLOW}Setting up private environment file...${NC}"
    mkdir -p "$CONFIG_DIR/zsh"
    cp "$DOTDIR/config/zsh/private-env-example.sh" "$CONFIG_DIR/zsh/.private-env.sh"
    chmod +x "$CONFIG_DIR/zsh/.private-env.sh"
    echo -e "${GREEN}Created private environment file${NC}"
fi

# 4. (optional) Create legacy symlinks for compatibility
echo -e "\n${YELLOW}Creating legacy symlinks for compatibility...${NC}"
# tmux
ln -sf "$CONFIG_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
# zsh
ln -sf "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"

echo -e "\n${GREEN}✅ Dotfiles successfully linked.${NC}"
echo "Next steps:"
echo "1. Restart your terminal or run 'source ~/.zshenv'"
echo "2. For tmux, press Ctrl+Space followed by 'I' to install plugins"
echo "3. For Neovim, simply open it to install plugins automatically"
