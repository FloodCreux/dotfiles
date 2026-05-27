require("noice").setup({
	-- snacks.notifier owns vim.notify rendering; noice handles
	-- cmdline / messages overlays only.
	notify = { enabled = false },
	lsp = {
		-- Override markdown rendering so completion docs use Treesitter.
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
	presets = {
		bottom_search = true,
		command_palette = false,
		long_message_to_split = true,
		inc_rename = false,
		lsp_doc_border = false,
	},
	routes = {
		{
			filter = {
				event = "msg_show",
				any = {
					{ find = "%d+L, %d+B" },
					{ find = "; after #%d+" },
					{ find = "; before #%d+" },
					{ find = "%d fewer lines" },
					{ find = "%d more lines" },
				},
			},
			opts = { skip = true },
		},
		{
			filter = {
				event = "lsp",
				kind = "progress",
				find = "metals",
			},
			opts = { skip = true },
		},
	},
})
