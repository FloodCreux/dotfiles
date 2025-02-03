vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("keymaps")
require("plugins.lazy")
require("plugins.misc")
require("options")
require("misc")
require("plugins.cmp")
require("plugins.conform")
require("plugins.dap")
require("plugins.gitsigns")
-- require("plugins.telescope")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.metals")
require("plugins.trouble")
-- require("plugins.obsidian")
require("plugins.zenmode")
require("plugins.neogit")
require("plugins.codesnap")
require("plugins.harpoon")
require("plugins.mini")

-- vim: ts=8 sts=2 sw=2 et
