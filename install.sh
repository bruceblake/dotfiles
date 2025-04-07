#!/bin/bash

# Create directories if they don't exist
mkdir -p ${HOME}/.config/nvim
mkdir -p ${HOME}/.oh-my-zsh

# Create symlinks
ln -sf $(pwd)/zsh/.zshrc ${HOME}/.zshrc
ln -sf $(pwd)/tmux/.tmux.conf ${HOME}/.tmux.conf
ln -sf $(pwd)/git/.gitconfig ${HOME}/.gitconfig
ln -sf $(pwd)/bash/.bashrc ${HOME}/.bashrc
ln -sf $(pwd)/bash/.bash_profile ${HOME}/.bash_profile

# Neovim config
ln -sf $(pwd)/nvim ${HOME}/.config/

echo "Dotfiles installed successfully!"