#!/bin/bash

# Simple diagnostic script to find out what's happening with editors

# Colors for feedback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== EDITOR DIAGNOSIS SCRIPT =====${NC}"
echo "This will diagnose issues with your editor setup."

echo -e "\n${YELLOW}CHECKING FOR EDITORS:${NC}"

# Check for system editors
echo -e "\n${YELLOW}System Editors:${NC}"
if command -v vim &> /dev/null; then
    echo -e "${GREEN}✓ vim found at $(which vim)${NC}"
    vim --version | head -n 1
else
    echo -e "${RED}✗ vim not found${NC}"
fi

if command -v nvim &> /dev/null; then
    echo -e "${GREEN}✓ nvim found at $(which nvim)${NC}"
    nvim --version | head -n 1 2>/dev/null || echo -e "${RED}  ✗ nvim found but not working${NC}"
else
    echo -e "${RED}✗ nvim not found${NC}"
fi

# Check for custom nvim scripts
echo -e "\n${YELLOW}Custom Editor Scripts:${NC}"
for path in ~/bin/nvim ~/.local/bin/nvim ~/my-nvim; do
    if [ -f "$path" ]; then
        if [ -x "$path" ]; then
            echo -e "${GREEN}✓ $path exists and is executable${NC}"
            echo "  Script contents:"
            echo "  -------------------"
            head -n 10 "$path" | sed 's/^/  /'
            echo "  -------------------"
        else
            echo -e "${YELLOW}! $path exists but is not executable${NC}"
        fi
    else
        echo -e "${RED}✗ $path does not exist${NC}"
    fi
done

# Check configuration
echo -e "\n${YELLOW}Configuration:${NC}"
if [ -d ~/.config/nvim ]; then
    echo -e "${GREEN}✓ ~/.config/nvim directory exists${NC}"
    if [ -L ~/.config/nvim ]; then
        echo -e "${GREEN}  ✓ It's a symlink pointing to $(readlink -f ~/.config/nvim)${NC}"
    else
        echo -e "${YELLOW}  ! It's a regular directory, not a symlink${NC}"
    fi
    
    # Check for minimal init.lua
    if [ -f ~/.config/nvim/init.lua ]; then
        echo -e "${GREEN}  ✓ init.lua exists${NC}"
    else
        echo -e "${RED}  ✗ init.lua missing${NC}"
    fi
else
    echo -e "${RED}✗ ~/.config/nvim directory does not exist${NC}"
fi

# Check PATH
echo -e "\n${YELLOW}PATH Environment:${NC}"
echo "Current PATH: $PATH"

echo -e "\n${YELLOW}Common PATH Locations:${NC}"
for pathDir in ~/bin ~/.local/bin /usr/bin /usr/local/bin /bin; do
    if [[ ":$PATH:" == *":$pathDir:"* ]]; then
        echo -e "${GREEN}✓ $pathDir is in PATH${NC}"
    else
        echo -e "${RED}✗ $pathDir is NOT in PATH${NC}"
    fi
done

# Check .zshrc
echo -e "\n${YELLOW}ZSH Configuration:${NC}"
if [ -f ~/.zshrc ]; then
    echo -e "${GREEN}✓ ~/.zshrc exists${NC}"
    
    # Check for editor-related entries
    echo -e "\n${YELLOW}Editor-related entries in .zshrc:${NC}"
    grep -E 'nvim|vim|EDITOR|bin|PATH' ~/.zshrc | grep -v "^#" || echo "No editor-related entries found."
else
    echo -e "${RED}✗ ~/.zshrc does not exist${NC}"
fi

echo -e "\n${YELLOW}===== DIAGNOSIS COMPLETE =====${NC}"
echo -e "Run ${GREEN}ultimate_reset.sh${NC} to completely reset your editor setup."