-- Diagnostic signs
-- https://github.com/folke/trouble.nvim/issues/52
local signs = {
	Error = " ",
	Warning = " ",
	Hint = " ",
	Information = " ",
}
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.diagnostic.config({
		signs = { text = icon, texthl = hl, numhl = hl },
	})
	-- vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end
