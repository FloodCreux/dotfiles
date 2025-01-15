-- require('telescope').load_extension('harpoon')
require("telescope").load_extension("git_worktree")

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require("telescope").setup({
	defaults = {
		layout_strategy = "horizontal",
		layout_config = {
			preview_width = 0.65,
			horizontal = {
				size = {
					width = "95%",
					height = "95%",
				},
			},
		},
		pickers = {
			find_files = {
				theme = "dropdown",
			},
		},
		mappings = {
			i = {
				["<C-u>"] = false,
				["<C-d>"] = false,
				["<C-j>"] = require("telescope.actions").move_selection_next,
				["<C-k>"] = require("telescope.actions").move_selection_previous,
				["<C-d>"] = require("telescope.actions").move_selection_previous,
			},
		},
	},
})

-- Enable telescope fzf native, if installed
pcall(require("telescope").load_extension, "fzf")

local wk = require("which-key")

wk.add({
	{ "<leader>f", group = "Telescope" },
	{ "<leader>ff", "<cmd> Telescope find_files<CR>", desc = "Find Files" },
	{ "<leader>fg", "<cmd> Telescope live_grep<CR>", desc = "Grep Files" },
	{ "<leader>fb", "<cmd> Telescope buffers<CR>", desc = "Search Buffers" },
	{ "<leader>fh", "<cmd> Telescope help_tags<CR>", desc = "Help Tags" },
	{ "<leader>fk", "<cmd> Telescope marks<CR>", desc = "Marks" },
	{ "<leader>fvc", "<cmd> Telescope git_commits<CR>" },
	{ "<leader>fvb", "<cmd> Telescope git_branches<CR>" },
	{ "<leader>fvs", "<cmd> Telescope git_status<CR>" },
	{ "<leader>fvx", "<cmd> Telescope git_stash<CR>" },
	{ "<leader>flsb", "<cmd> Telescope lsp_document_symbols<CR>" },
	{ "<leader>flsw", "<cmd> Telescope lsp_workspace_symbols<CR>" },
	{ "<leader>flr", "<cmd> Telescope lsp_references<CR>" },
	{ "<leader>fli", "<cmd> Telescope lsp_implementations<CR>" },
	{ "<leader>flD", "<cmd> Telescope lsp_definitions<CR>" },
	{ "<leader>flt", "<cmd> Telescope lsp_type_definitions<CR>" },
	{ "<leader>fld", "<cmd> Telescope diagnostics<CR>" },
	{ "<leader>fi", "<cmd> Telescope media_files<CR>" },
	{ "<leader>fts", "<cmd> Telescope treesitter<CR>" },
})
-- -- See `:help telescope.builtin`
-- vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
-- vim.keymap.set("n", "<leader>/", function()
-- 	-- You can pass additional configuration to telescope to change theme, layout, etc.
-- 	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
-- 		winblend = 10,
-- 		previewer = true,
-- 	}))
-- end, { desc = "[/] Fuzzily search in current buffer]" })
--
-- vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
-- -- vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
-- vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
-- vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
-- vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
-- vim.keymap.set("n", "<leader>sb", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
-- vim.keymap.set("n", "<leader>sS", require("telescope.builtin").git_status, { desc = "" })
-- vim.keymap.set("n", "<leader>sm", ":Telescope harpoon marks<CR>", { desc = "Harpoon [M]arks" })
-- vim.keymap.set("n", "<Leader>sr", "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>", silent)
-- vim.keymap.set(
-- 	"n",
-- 	"<Leader>sR",
-- 	"<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
-- 	silent
-- )
-- vim.keymap.set("n", "<Leader>sn", "<CMD>lua require('telescope').extensions.notify.notify()<CR>", silent)
--
-- vim.api.nvim_set_keymap("n", "st", ":TodoTelescope<CR>", { noremap = true })
-- vim.api.nvim_set_keymap(
-- 	"n",
-- 	"<Leader><tab>",
-- 	"<Cmd>lua require('telescope.builtin').commands()<CR>",
-- 	{ noremap = false }
-- )
