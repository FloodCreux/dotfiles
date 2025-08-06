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
	gh("hrsh7th/cmp-nvim-lsp"),
	gh("L3MON4D3/LuaSnip"),
	gh("saadparwaiz1/cmp_luasnip"),
	gh("hrsh7th/cmp-path"),
	gh("igorlfs/nvim-dap-view"),
	gh("nvim-neotest/nvim-nio"),

	-- LSP
	gh("mason-org/mason.nvim"),
	gh("scalameta/nvim-metals"),
	gh("stevearc/conform.nvim"),
	gh("benomahony/uv.nvim"),

	-- Debug
	gh("mfussenegger/nvim-dap"),
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

	-- Mini
	gh("echasnovski/mini.ai"),
	gh("echasnovski/mini.bracketed"),
	gh("echasnovski/mini.completion"),
	gh("echasnovski/mini.files"),
	gh("echasnovski/mini.icons"),
	gh("echasnovski/mini.indentscope"),
	gh("echasnovski/mini.hipatterns"),
	gh("echasnovski/mini.pick"),
	gh("echasnovski/mini.snippets"),
	gh("echasnovski/mini.statusline"),

	-- Color Schemes
	gh("blazkowolf/gruber-darker.nvim"),
	gh("catppuccin/nvim", { name = "catppuccin" }),

	-- File Manager
	gh("mikavilpas/yazi.nvim"),
	gh("nvim-treesitter/nvim-treesitter"),

	-- Notifications
	gh("folke/noice.nvim"),

	-- Snippets
	gh("hrsh7th/nvim-cmp"),
}

return M
