-- Highlight on yank (see `:help vim.hl.on_yank()`)
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- C3 filetype detection
vim.filetype.add({
	extension = {
		c3 = "c3",
		c3i = "c3i",
	},
})
