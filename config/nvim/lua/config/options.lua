-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
--
vim.opt.termguicolors = true
vim.g.have_nerd_font = true

local opt = vim.opt

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"
