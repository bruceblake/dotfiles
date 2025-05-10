#!/usr/bin/env bash
set -e

# Cleanup script to remove backup files and restore pristine state

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== DOTFILES CLEANUP =====${NC}"
echo "This script will clean up backup files and restore the repository to a pristine state."

# Ask for confirmation
read -p "This may remove backup files. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 0
fi

# Files and directories that are essential for the repository
ESSENTIAL_FILES=(
  "config"
  "README.md"
  "bootstrap.sh"
  "install.sh"
  "update.sh"
  "install_windows_fonts.sh"
  "cleanup.sh"
  ".git"
  ".gitignore"
  ".gitmodules"
)

# Backup files that may have been created
BACKUP_PATTERNS=(
  "*.backup.*"
  "*.bak"
  "*.old"
  "*~"
  "*.swp"
  ".DS_Store"
  "Thumbs.db"
)

# Clean up backup files
echo -e "\n${YELLOW}Cleaning up backup files...${NC}"
for pattern in "${BACKUP_PATTERNS[@]}"; do
    echo "Finding and removing $pattern..."
    find . -name "$pattern" -type f -delete 2>/dev/null || true
done

# Remove non-essential files in the root directory
echo -e "\n${YELLOW}Checking for non-essential files...${NC}"
for file in *; do
    if [ -e "$file" ]; then  # Check if file exists (handles weird filenames)
        keep=false
        for essential_file in "${ESSENTIAL_FILES[@]}"; do
            if [ "$file" == "$essential_file" ]; then
                keep=true
                break
            fi
        done
        
        if [ "$keep" == "false" ]; then
            echo "Found non-essential file: $file"
            read -p "Remove this file? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Removing $file..."
                rm -rf "$file"
            else
                echo "Keeping $file..."
            fi
        fi
    fi
done

# Clean up temporary directories that might have been created
echo -e "\n${YELLOW}Cleaning up temporary directories...${NC}"
TEMP_DIRS=("tmp" "temp" ".tmp" ".temp")
for dir in "${TEMP_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "Removing temporary directory: $dir"
        rm -rf "$dir"
    fi
done

# Clean up zsh .zcompdump files
if [ -d "config/zsh" ]; then
    echo -e "\n${YELLOW}Cleaning up zsh cache files...${NC}"
    find config/zsh -name ".zcompdump*" -type f -delete 2>/dev/null || true
fi

# Clean local git repo (optionally)
echo -e "\n${YELLOW}Git repository maintenance${NC}"
read -p "Run git garbage collection to optimize repository? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running git garbage collection..."
    git gc --aggressive --prune=now
fi

echo -e "\n${GREEN}✅ Cleanup complete!${NC}"
echo "The repository has been cleaned up and is ready for use."