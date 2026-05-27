-- [[ Configure Treesitter (nvim-treesitter `main` branch) ]]
-- See `:help nvim-treesitter` and https://github.com/nvim-treesitter/nvim-treesitter

local install_dir = vim.fn.stdpath("data") .. "/site"
vim.opt.runtimepath:prepend(install_dir)

-- Register custom parsers (nu, c3) via the `User TSUpdate` hook so `:TSUpdate`
-- and `:TSInstall` know about them.
vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = function()
		local parsers = require("nvim-treesitter.parsers")
		parsers.nu = {
			install_info = {
				url = "https://github.com/nushell/tree-sitter-nu",
				branch = "main",
			},
		}
		parsers.c3 = {
			install_info = {
				url = "https://github.com/c3lang/tree-sitter-c3",
				branch = "main",
			},
		}
	end,
})

require("nvim-treesitter").setup({
	install_dir = install_dir,
})

-- Parsers to install. Installation is asynchronous; this is a no-op once
-- they are present.
local ensure_installed = {
	"bash",
	"c3",
	"css",
	"go",
	"helm",
	"html",
	"javascript",
	"json",
	"kdl",
	"lua",
	"markdown",
	"markdown_inline",
	"nu",
	"python",
	"regex",
	"rust",
	"scala",
	"scss",
	"sql",
	"svelte",
	"terraform",
	"tmux",
	"tsx",
	"typescript",
	"typst",
	"toml",
	"vue",
	"yaml",
	-- Note: `ghostty` is installed via the `tree-sitter-ghostty` plugin's
	-- own `make nvim_install` build step, not through nvim-treesitter.
}

require("nvim-treesitter").install(ensure_installed)

-- Enable highlighting for every installed/known parser via a single FileType
-- autocmd. `go` is disabled intentionally (matches the previous config).
local disabled_highlight = { go = true }
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local ft = args.match
		if disabled_highlight[ft] then
			return
		end
		local lang = vim.treesitter.language.get_lang(ft) or ft
		pcall(vim.treesitter.start, args.buf, lang)
	end,
})

-- ---------------------------------------------------------------------------
-- nvim-treesitter-textobjects (also `main`-branch new API)
-- ---------------------------------------------------------------------------
local ok_to, textobjects = pcall(require, "nvim-treesitter-textobjects")
if ok_to then
	textobjects.setup({
		select = {
			lookahead = true,
		},
		move = {
			set_jumps = true,
		},
	})
end
