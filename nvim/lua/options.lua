-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.o.relativenumber = true

-- Tab Spacing
vim.opt.shiftwidth = 3
vim.opt.tabstop = 3

-- Disable mouse mode
vim.o.mouse = "a"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

-- Set colorscheme
--vim.cmd [[colorscheme onedark]]
vim.cmd.colorscheme("gruber-darker")

--vim.cmd()
vim.opt.clipboard = "unnamedplus"

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Concealer for Neorg
vim.o.conceallevel = 2

vim.o.guicursor = ""

vim.o.scrolloff = 10

vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.showmode = false

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.modifiable = true
