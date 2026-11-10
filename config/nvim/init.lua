-- Baseline neovim config. Replace the whole config/nvim/ folder with your own.
vim.g.mapleader = " "
local o = vim.opt
o.number = true
o.relativenumber = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.ignorecase = true
o.smartcase = true
o.clipboard = "unnamedplus"
o.termguicolors = true
o.undofile = true
o.signcolumn = "yes"
o.scrolloff = 8
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
