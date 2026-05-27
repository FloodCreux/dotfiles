-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- Set filetype for .razor files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.razor",
	callback = function()
		vim.bo.filetype = "cs"
	end,
})

-- Set filetype for C3 files
vim.filetype.add({
	extension = {
		c3 = "c3",
		c3i = "c3i",
	},
})

-- Treesitter highlighting attachment is now handled centrally in
-- lua/plugins/treesitter.lua via a single FileType autocmd, so the previous
-- c3-specific hook is no longer needed.

-- LSP progress notifications are handled by fidget.nvim (see plugins/init.lua).
