local M = {}

local lspconfig = require("utils.lspconfig")

M.map = vim.keymap.set

for k, v in pairs(lspconfig) do
	M[k] = v
end

return M
