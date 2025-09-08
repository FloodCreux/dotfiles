local function gh(repo, opts)
	opts = opts or {}
	opts.src = "https://github.com/" .. repo
	return opts
end

local M = {
	-- Dependencies
	gh("nvim-lua/plenary.nvim"),
	gh("j-hui/fidget.nvim"),
	gh("MunifTanjim/nui.nvim"),
	gh("rcarriga/nvim-notify"),
	gh("igorlfs/nvim-dap-view"),
	gh("nvim-neotest/nvim-nio"),
	-- gh("nvim-tree/nvim-web-devicons"),

	-- Snippets
	gh("L3MON4D3/LuaSnip"),

	-- Package Manager
	gh("adriankarlen/plugin-view.nvim"),

	-- Completion
	-- gh("hrsh7th/nvim-cmp"),
	-- gh("hrsh7th/cmp-nvim-lsp"),
	-- gh("saadparwaiz1/cmp_luasnip"),
	-- gh("hrsh7th/cmp-path"),

	-- LSP
	gh("mason-org/mason.nvim"),
	gh("scalameta/nvim-metals"),
	gh("stevearc/conform.nvim"),
	gh("benomahony/uv.nvim"),
	-- gh("OXY2DEV/markview.nvim"),
	gh("MeanderingProgrammer/render-markdown.nvim"),

	-- Debug
	gh("mfussenegger/nvim-dap"),
	gh("mfussenegger/nvim-dap-python"),
	gh("nvim-neotest/nvim-nio"),
	gh("rcarriga/nvim-dap-ui"),
	gh("folke/trouble.nvim"),

	-- TPope
	gh("tpope/vim-fugitive"),
	gh("tpope/vim-sleuth"),
	gh("tpope/vim-obsession"),
	gh("tpope/vim-dadbod"),
	gh("kristijanhusak/vim-dadbod-completion"),
	gh("kristijanhusak/vim-dadbod-ui"),

	-- Git
	gh("lewis6991/gitsigns.nvim"),
	gh("neogitorg/neogit"),

	-- Folke
	gh("folke/snacks.nvim"),
	gh("folke/which-key.nvim"),

	-- Mini
	gh("nvim-mini/mini.ai"),
	gh("nvim-mini/mini.bracketed"),
	gh("nvim-mini/mini.completion"),
	gh("nvim-mini/mini.files"),
	gh("nvim-mini/mini.icons"),
	gh("nvim-mini/mini.indentscope"),
	gh("nvim-mini/mini.hipatterns"),
	gh("nvim-mini/mini.pick"),
	gh("nvim-mini/mini.snippets"),
	gh("nvim-mini/mini.statusline"),

	-- Color Schemes
	gh("blazkowolf/gruber-darker.nvim"),
	-- gh("catppuccin/nvim", { name = "catppuccin" }),

	-- File Manager
	gh("mikavilpas/yazi.nvim"),
	gh("nvim-treesitter/nvim-treesitter", { version = "main" }),
	gh("nvim-treesitter/nvim-treesitter-textobjects"),

	-- Notifications
	gh("folke/noice.nvim"),
}

return M
