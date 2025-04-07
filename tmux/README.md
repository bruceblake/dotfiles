# Tmux Configuration

This is a customized tmux configuration with:

- Dracula/purple theme for the status bar
- Tmux Plugin Manager (TPM) for managing plugins
- Custom keybindings including:
  - `Ctrl+Space` as the prefix key
  - Vim-like keybindings for copy mode
  - Alt+H/L for window navigation
  - Vi mode for navigation

## Included Plugins

- tmux-sensible: Sensible defaults
- vim-tmux-navigator: Seamless navigation between tmux panes and vim
- tmux-yank: Better clipboard support
- tmux-online-status: Display online/offline status
- tmux-resurrect: Save/restore tmux sessions
- tmux-continuum: Automatic save/restore
- tmux-weather: Weather information in the status bar
- tmux-git: Git information in the status bar

## Installation

The installation script will:
1. Create the necessary directories
2. Install TPM (Tmux Plugin Manager)
3. Set up appropriate symlinks

After installation, start tmux and press `prefix` + `I` (capital I) to install plugins.

## Manual Setup

If you're setting up manually:

```bash
# Create directories
mkdir -p ~/.tmux/plugins
mkdir -p ~/.config/tmux

# Clone TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Link configuration
ln -sf /path/to/dotfiles/tmux/.tmux.conf ~/.config/tmux/tmux.conf
ln -sf /path/to/dotfiles/tmux/.tmux.conf ~/.tmux.conf

# Start tmux and install plugins
# Press prefix + I (capital I)
```