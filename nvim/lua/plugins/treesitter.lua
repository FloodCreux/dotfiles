-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- vim.cmd("TSUpdate")

-- Configure custom parsers BEFORE setup
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.nu = {
	install_info = {
		url = "https://github.com/nushell/tree-sitter-nu",
		files = { "src/parser.c", "src/scanner.c" },
		branch = "main",
	},
	filetype = "nu",
}

parser_config.c3 = {
	install_info = {
		url = "https://github.com/c3lang/tree-sitter-c3",
		files = { "src/parser.c", "src/scanner.c" },
		branch = "main",
	},
	filetype = "c3",
}

---@diagnostic disable-next-line
require("nvim-treesitter.configs").setup({
	-- Add languages to be installed here that you want installed for treesitter
	ensure_installed = {
		"bash",
		"c3",
		"css",
		"ghostty",
		"go",
		"helm",
		"html",
		"javascript",
		"json",
		"kdl",
		"latex",
		"lua",
		"markdown",
		"markdown_inline",
		"norg",
		"nu",
		"org",
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
	},

	highlight = {
		enable = true,
		disable = { "go" },
	},
	indent = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<c-space>",
			node_incremental = "<c-space>",
			scope_incremental = "<c-s>",
			node_decremental = "<c-backspace>",
		},
	},
	textobjects = {
		select = {
			enable = false,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				-- ['aF'] = '@function.outer',
				-- ['iF'] = '@function.inner',
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["ii"] = "@conditional.inner",
				["ai"] = "@conditional.outer",
				-- ['il'] = '@loop.inner',
				-- ['al'] = '@loop.outer',
				["at"] = "@comment.outer",
			},
		},
		move = {
			enable = false,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]f"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]F"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[f"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[F"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>a"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>A"] = "@parameter.inner",
			},
		},
	},
})
