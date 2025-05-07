-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local function cmd(command)
  return table.concat({ "<Cmd>", command, "<CR>" })
end

vim.keymap.set("n", "<leader><Left>", cmd("TmuxNavigateLeft"))
vim.keymap.set("n", "<leader><Down>", cmd("TmuxNavigateDown"))
vim.keymap.set("n", "<leader><Up>", cmd("TmuxNavigateUp"))
vim.keymap.set("n", "<leader><Right>", cmd("TmuxNavigateRight"))

vim.keymap.set(
  "n",
  "<leader>wt",
  ":lcd %:p:h | split | terminal<CR>",
  { silent = true, desc = "Split Terminal Vertically" }
)

vim.api.nvim_set_keymap("t", "<C-space>", "<C-\\><C-n>:CFloatTerm<CR>", { noremap = true, silent = true })

local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-a>", { desc = "Decrement number" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-n>", "<cmd>silent !tmux new tmux-sessionizer<CR>")
