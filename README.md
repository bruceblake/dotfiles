# Dotfiles

My personal dotfiles for development environments, featuring configurations for Neovim, tmux, zsh, and more.

## Overview

This repository contains configuration files for:

- **Neovim**: A modern, improved version of Vim
- **tmux**: Terminal multiplexer
- **zsh**: Z shell configuration
- **git**: Git configuration

## Prerequisites

- Git
- GNU Stow (for managing symlinks)
- Neovim
- tmux
- zsh
- [Optional] Oh My Zsh
- A Nerd Font for proper icon rendering (recommended: MesloLGS NF)

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the installation script
./install.sh
```

### Manual Installation

If you prefer to install components manually:

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the bootstrap script to create symlinks:
   ```bash
   ./bootstrap.sh
   ```

3. For individual components:
   ```bash
   # All configs at once
   stow -R --dir="$HOME/.dotfiles" --target="$HOME/.config" config
   
   # Or individual configs
   stow -R --dir="$HOME/.dotfiles" --target="$HOME/.config/nvim" config/nvim
   stow -R --dir="$HOME/.dotfiles" --target="$HOME/.config/tmux" config/tmux
   stow -R --dir="$HOME/.dotfiles" --target="$HOME/.config/zsh" config/zsh
   ```

## Directory Structure

```
~/.dotfiles/
├── config/            # XDG-compliant config files
│   ├── nvim/          # Neovim configuration
│   ├── tmux/          # tmux configuration
│   ├── zsh/           # zsh configuration
│   └── git/           # Git configuration
├── bootstrap.sh       # Script to create symlinks
├── install.sh         # Main installation script
└── update.sh          # Update plugins and configurations
```

## After Installation

### Neovim

- Open Neovim for the first time to install plugins automatically
- Run `:checkhealth` to verify everything is working

### tmux

- Press `Ctrl+Space` followed by `I` to install plugins

### zsh

- Restart your terminal or run `source ~/.zshenv` to apply changes

## Customization

### Private Environment Variables

Copy the example file and customize it:

```bash
cp ~/.dotfiles/config/zsh/private-env-example.sh ~/.config/zsh/.private-env.sh
```

## Updating

To update all plugins and configurations:

```bash
cd ~/.dotfiles
./update.sh
```

## Troubleshooting

### Font Issues

If you're seeing icon issues in Neovim:
- Make sure your terminal is using a Nerd Font (MesloLG Nerd Font recommended)
- In your terminal settings, set font to 'MesloLGS NF' or similar

## License

MIT