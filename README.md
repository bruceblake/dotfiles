# Dotfiles

My personal dotfiles for Linux systems.

## What's included

- Zsh configuration with Oh My Zsh
- Neovim configuration
- Tmux configuration with custom theme & plugins
- Git configuration
- Bash configuration

## Prerequisites

### Nerd Fonts

Many configurations use special symbols from Nerd Fonts. Install them by:

```bash
# Create fonts directory
mkdir -p ~/.local/share/fonts

# Download and install a Nerd Font (using Meslo as an example)
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip
unzip Meslo.zip -d ~/.local/share/fonts
rm Meslo.zip

# Refresh font cache
fc-cache -fv
```

You can choose any Nerd Font from https://www.nerdfonts.com/font-downloads

### Software Requirements

- git
- tmux
- zsh
- Oh My Zsh
- neovim (version 0.9+)

## Installation

```bash
# Clone the repository with submodules
git clone --recurse-submodules https://github.com/bruceblake/dotfiles.git
cd dotfiles

# Run the installation script
./install.sh
```

## After Installation

### Tmux
Start tmux and install plugins by pressing `Ctrl+Space` then `I` (capital i).

### Neovim
Start neovim, and it will automatically install plugins on first run.

## Manual Installation

If you prefer to install files individually:

1. Create symlinks for each configuration file
2. Make sure to backup your existing configuration first
3. Follow component-specific installation instructions in their README files

## License

MIT