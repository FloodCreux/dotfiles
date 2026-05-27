vim.o.termguicolors = true

-- Line numbers
vim.wo.number = true
vim.o.relativenumber = true

-- Tab spacing
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Enable mouse in all modes (including command line)
vim.o.mouse = "a"

-- Wrapped lines keep indent
vim.o.breakindent = true

-- Persistent undo
vim.o.undofile = true

-- Smart case search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Faster CursorHold / diagnostics + always-on sign column
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

-- Colorscheme
vim.cmd.colorscheme("gruber-darker")

-- System clipboard for all yank/put
vim.opt.clipboard = "unnamedplus"

-- Completion menu behavior
vim.o.completeopt = "menu,menuone,noselect"

-- Conceal level (markdown rendering, etc.)
vim.o.conceallevel = 2

-- Keep terminal block cursor in all modes
vim.o.guicursor = ""

-- Keep 10 lines of context around cursor
vim.o.scrolloff = 10

-- No swap files
vim.opt.swapfile = false

-- Mode shown by statusline, not the command area
vim.opt.showmode = false

-- Rounded borders for floating windows
vim.o.winborder = "rounded"

-- NixOS system path (no-op elsewhere)
if vim.uv.os_uname().sysname == "Linux" and vim.uv.fs_stat("/run/current-system/sw/bin") then
	vim.env.PATH = vim.env.PATH .. ":/run/current-system/sw/bin"
end
