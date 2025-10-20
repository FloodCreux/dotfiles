local utils = require("utils")
local map = utils.map

vim.g.opencode_opts = {
	-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on `opencode_opts`.
}

-- Required for `vim.g.opencode_opts.auto_reload`.
vim.o.autoread = true

-- Recommended/example keymaps.
map({ "n", "x" }, "<leader>oa", function()
	require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask about this" })
map({ "n", "x" }, "<leader>os", function()
	require("opencode").select()
end, { desc = "Select prompt" })
map({ "n", "x" }, "<leader>o+", function()
	require("opencode").prompt("@this")
end, { desc = "Add this" })
map("n", "<leader>ot", function()
	require("opencode").toggle()
end, { desc = "Toggle embedded" })
map("n", "<leader>oc", function()
	require("opencode").command()
end, { desc = "Select command" })
map("n", "<leader>on", function()
	require("opencode").command("session_new")
end, { desc = "New session" })
map("n", "<leader>oi", function()
	require("opencode").command("session_interrupt")
end, { desc = "Interrupt session" })
map("n", "<leader>oA", function()
	require("opencode").command("agent_cycle")
end, { desc = "Cycle selected agent" })
map("n", "<S-C-u>", function()
	require("opencode").command("messages_half_page_up")
end, { desc = "Messages half page up" })
map("n", "<S-C-d>", function()
	require("opencode").command("messages_half_page_down")
end, { desc = "Messages half page down" })
