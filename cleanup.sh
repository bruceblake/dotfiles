#!/bin/bash

# Cleanup script to remove unnecessary files

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== CLEANING UP REPOSITORY =====${NC}"
echo "This script will remove all files except those needed for tmux, nvim, and zsh."

# Ask for confirmation
read -p "This is a destructive operation. Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Files to keep
KEEP_FILES=(
  "nvim"
  "tmux"
  "zsh"
  "README.md"
  "simple_install.sh"
  ".git"
  ".gitignore"
  ".gitmodules"
)

# Remove files that aren't in the keep list
echo -e "\n${YELLOW}Removing unnecessary files...${NC}"
for file in *; do
    keep=false
    for keep_file in "${KEEP_FILES[@]}"; do
        if [ "$file" == "$keep_file" ]; then
            keep=true
            break
        fi
    done
    
    if [ "$keep" == "false" ] && [ "$file" != "cleanup.sh" ]; then
        echo "Removing $file..."
        rm -rf "$file"
    fi
done

# Remove Git-related directories (bash and git)
echo "Removing bash and git directories..."
rm -rf bash
rm -rf git

echo -e "\n${GREEN}Cleanup complete!${NC}"
echo "The repository now contains only essential files for tmux, nvim, and zsh."
echo "You should commit these changes to your repository."