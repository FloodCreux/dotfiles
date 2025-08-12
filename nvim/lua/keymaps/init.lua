local utils = require("keymaps.utils")
local map = utils.map

map("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

map({ "n", "v", "x" }, "<leader>s", ":e #<CR>")

map("n", "<esc><esc>", "<cmd>nohlsearch<cr>", { silent = true })

map("n", "<leader>pv", "<cmd>Yazi<cr>")

require("keymaps.snacks")
require("keymaps.snippets")
require("keymaps.trouble")
