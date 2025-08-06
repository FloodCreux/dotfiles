vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("keymaps")

vim.pack.add(require("packages"))

require("options")
require("misc")
require("plugins")
