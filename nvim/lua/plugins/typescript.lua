local utils = require("utils")
local map = utils.map

local function project_root(bufnr)
	local markers =
		{ "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", "tsconfig.json", ".git" }

	return vim.fs.root(bufnr or 0, markers) or vim.fn.getcwd()
end

vim.api.nvim_create_user_command("TscCheck", function()
	local root = project_root()
	local efm = [[%f(%l\,%c): error TS%n: %m]]

	vim.notify("Running tsc --noEmit...", vim.log.levels.INFO)

	vim.system(
		{ "npx", "tsc", "--noEmit", "--pretty", "false" },
		{ cwd = root, text = true },
		vim.schedule_wrap(function(out)
			local lines = vim.split((out.stdout or "") .. (out.stderr or ""), "\n", { trimempty = true })

			local items = vim.fn.getqflist({ lines = lines, efm = efm }).items
			items = vim.tbl_filter(function(it)
				return it.valid == 1
			end, items)

			vim.fn.setqflist({}, "", {
				title = "tsc --noEmit",
				items = items,
			})

			if #items == 0 then
				vim.notify("tsc: no type errors ✔", vim.log.levels.INFO)
				return
			end

			vim.notify(("tsc: %d type error(s)"):format(#items), vim.log.levels.WARN)

			local ok = pcall(vim.cmd, "Trouble qflist open")
			if not ok then
				vim.cmd("copen")
			end
		end)
	)
end, { desc = "Project-wide tsc --noEmit type check into quickfix/Trouble" })

map("n", "<leader>tc", "<cmd>TscCheck<cr>")
