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

		sources = {
			files = {
				hidden = true,
				ignored = true,
				exclude = {
					-- Version Control
					".git/",
					".svn/",
					".hg/",

					-- Build & Dependency Directories
					"node_modules/",
					"target/",
					"build/",
					"dist/",
					"out/",
					"vendor/",
					".next/",
					".nuxt/",

					-- Cache & Temporary Files
					".cache/",
					".gradle/",
					".maven/",
					".pytest_cache/",
					".mypy_cache/",
					".turbo/",
					".parcel-cache/",
					"*.pyc",

					-- IDE & Editor Files
					".idea/",
					".vscode/",
					".DS_Store",
					"*.swp",
					"*.swo",

					-- Language-Specific Build/Cache
					".metals/",
					".bloop/",
					"*.class",
					"*.semanticdb",
					"venv/",
					".venv/",
					"__pycache__/",

					-- Minified & Generated Files
					"*.min.js",
					"*.min.css",
					"*.map",

					-- Test Coverage & Logs
					"coverage/",
					".nyc_output/",
					"*.log",
				},
			},

			grep = {
				layout = { preset = "ivy_split" },
				auto_close = false,
				jump = {
					close = false,
					reuse_win = true,
				},
			},

			lsp_references = {
				layout = { preset = "ivy_split" },
				jump = { close = false },
			},
		},
	},
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = false },
	statuscolumn = { enabled = false },
	words = { enabled = true },
})
