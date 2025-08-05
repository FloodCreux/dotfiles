local map = vim.keymap.set

map("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

map({ "n", "v" }, "<leader>y", [["+y]])

map("n", "<leader>Y", [["+Y]])
map("n", "<esc><esc>", "<cmd>nohlsearch<cr>", { silent = true })

map("n", "<leader>pv", "<cmd>Yazi<cr>")
map("n", "<leader>ff", function()
	Snacks.picker.smart()
end)
map("n", "<leader>fg", function()
	Snacks.picker.grep()
end)
map("n", "<leader>n", function()
	Snacks.picker.notifications()
end)
map("n", "<leader>gg", function()
	Snacks.lazygit()
end)

map({ "n", "v", "x" }, "<leader>s", ":e #<CR>")
