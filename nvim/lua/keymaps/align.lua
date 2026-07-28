local utils = require("utils")
local map = utils.map

map("x", "ga", function()
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")
	local start_line = math.min(start_pos[2], end_pos[2])
	local end_line = math.max(start_pos[2], end_pos[2])

	local char = vim.fn.input("Align on character: ", "=")
	if char == "" then
		char = "="
	end
	local esc = vim.fn.shellescape(char)
	local cmd = "awk -v c="
		.. esc
		.. [[ '{i=index($0,c); if(i) $0=substr($0,1,i-1) "\001" substr($0,i+length(c))} 1' | column -t -s$'\001' -o]]
		.. esc
	-- vim.cmd(string.format("%d,%d!column -t -s%s -o%s", start_line, end_line, esc, esc))
	vim.cmd(string.format("%d,%d!%s", start_line, end_line, cmd))
end, { desc = "Align visual selection on character" })
