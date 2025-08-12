local utils = require("keymaps.utils")
local map = utils.map

local ls = require("luasnip")
map("i", "<C-e>", function()
	ls.expand_or_jump(1)
end, { silent = true })
-- map({ "i", "s" }, "<C-J>", function() ls.jump(1) end, { silent = true })
map({ "i", "s" }, "<C-K>", function()
	ls.jump(-1)
end, { silent = true })
