vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("keymaps")

vim.pack.add({
	-- Deps
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/rcarriga/nvim-notify" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/saadparwaiz1/cmp_luasnip" },
	{ src = "https://github.com/hrsh7th/cmp-path" },
	-- Lsp
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/scalameta/nvim-metals" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	-- { src = "https://github.com/onsails/lspkind.nvim" },
	-- TPope
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/tpope/vim-sleuth" }, -- Detect tabstop and shiftwidth automatically
	{ src = "https://github.com/tpope/vim-obsession" },
	{ src = "https://github.com/tpope/vim-dadbod" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-completion" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
	-- Git
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	-- Folke
	{ src = "https://github.com/folke/snacks.nvim" },
	-- Mini
	{ src = "https://github.com/echasnovski/mini.ai" },
	{ src = "https://github.com/echasnovski/mini.bracketed" },
	{ src = "https://github.com/echasnovski/mini.completion" },
	{ src = "https://github.com/echasnovski/mini.files" },
	{ src = "https://github.com/echasnovski/mini.icons" },
	{ src = "https://github.com/echasnovski/mini.indentscope" },
	{ src = "https://github.com/echasnovski/mini.hipatterns" },
	-- { src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/echasnovski/mini.snippets" },
	{ src = "https://github.com/echasnovski/mini.statusline" },
	-- Color Schemes
	{ src = "https://github.com/blazkowolf/gruber-darker.nvim" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	-- File Manager
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	-- { src = "https://github.com/ThePrimeagen/git-worktree.nvim" },
	-- Notifications
	{ src = "https://github.com/folke/noice.nvim" },
	-- Snippets
	{ src = "https://github.com/hrsh7th/nvim-cmp" },
})

require("options")
require("misc")
require("plugins")

-- vim: ts=8 sts=2 sw=2 et
