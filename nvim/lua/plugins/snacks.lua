require("snacks").setup({
	bigfile = { enabled = true },
	dashboard = { enabled = false },
	explorer = { enabled = false },
	indent = { enabled = true },
	input = { enabled = true },
	lazygit = {
		enabled = true,
		configure = false,
		config = {
			os = { editPreset = "nvim-remote" },
		},
	},
	notifier = {
		enabled = true,
		timeout = 3000,
	},
	picker = {
		enabled = true,
		hidden = true,
		ignored = true,

		sources = {
			files = {
				hidden = true,
				ignored = true,
				exclude = {
					".git/",
					".metals/",
					".bloop/",
					"*.class",
					"*.semanticdb",
				},
			},
		},
	},
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = false },
	statuscolumn = { enabled = false },
	words = { enabled = true },
	styles = {
		notification = {
			-- wo = { wrap = true } -- Wrap notifications
		},
	},
})
