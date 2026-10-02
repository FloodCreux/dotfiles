require("mini.ai").setup({
	n_lines = 500,
})
require("mini.bracketed").setup()
require("mini.completion").setup({
	window = {
		info = { height = 25, width = 60, border = "none" },
		signature = { height = 10, width = 60, border = "none" },
	},
})
require("mini.files").setup()
require("mini.icons").setup()

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
	highlighters = {
		-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
		fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
		hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
		todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
		note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

		-- Highlight hex color strings (`#rrggbb`) using that color
		hex_color = hipatterns.gen_highlighter.hex_color(),
		-- cells = require("notebook-navigator").minihipatterns_spec,
	},
})

local gen_loader = require("mini.snippets").gen_loader
require("mini.snippets").setup({
	snippets = {
		gen_loader.from_lang(),
	},
})

local statusline = require("mini.statusline")
-- set use_icons to true if you have a Nerd Font
statusline.setup({ use_icons = vim.g.have_nerd_font })

-- You can configure sections in the statusline by overriding their
-- default behavior. For example, here we set the section for
-- cursor location to LINE:COLUMN
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
	return "%2l:%-2v"
end

-- require("mini.surround").setup()
-- require("mini.operators").setup()
-- require("mini.pairs").setup()

-- Stop any lingering snippet session when leaving Insert/Select mode, so
-- empty-tabstop markers (• / ∎) never stay on screen in Normal mode.
vim.api.nvim_create_autocmd("ModeChanged", {
	group = vim.api.nvim_create_augroup("MiniSnippetsAutoStop", { clear = true }),
	pattern = "*:n",
	callback = function()
		while require("mini.snippets").session.get() do
			require("mini.snippets").session.stop()
		end
	end,
	desc = "Stop snippet sessions on exit to Normal model",
})
