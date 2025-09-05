local dap = require("dap")
local dapui = require("dapui")
-- local dapui = require("dap-view")
local dappy = require("dap-python")

vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>B", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set Breakpoint" })

-- local debugpy_path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
-- dappy.setup(debugpy_path)
dappy.setup("uv")

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
-- dapui.setup({
--    -- Set icons to characters that are more likely to work in every terminal.
--    --    Feel free to remove or use ones that you like more! :)
--    --    Don't feel like these are good choices.
--    icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
--    controls = {
--       icons = {
--          pause = "⏸",
--          play = "▶",
--          step_into = "⏎",
--          step_over = "⏭",
--          step_out = "⏮",
--          step_back = "b",
--          run_last = "▶▶",
--          terminate = "⏹",
--          disconnect = "⏏",
--       },
--    },
-- })

dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

require("neodev").setup({
	library = { plugins = { "nvim-dap-ui" }, types = true },
	lspconfig = true,
})

if not dap.adapters["netcoredbg"] then
	require("dap").adapters["netcoredbg"] = {
		type = "executable",
		command = vim.fn.exepath("netcoredbg"),
		args = { "--interpreter=vscode" },
	}
end
for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
	if not dap.configurations[lang] then
		dap.configurations[lang] = {
			{
				type = "netcoredbg",
				name = "Launch file",
				request = "launch",
				---@diagnostic disable-next-line: redundant-parameter
				program = function()
					return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "$${workspaceFolder}",
			},
		}
	end
end

require("dap-go").setup({})

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "My custom launch configuration",
		program = "${file}",
	},
}

dap.configurations.scala = {
	{
		type = "scala",
		request = "launch",
		name = "RunOrTest",
		metals = {
			runType = "runOrTestFile",
			--args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
			args = { "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED" },
		},
	},
	{
		type = "scala",
		request = "launch",
		name = "Test Target",
		metals = {
			runType = "testTarget",
		},
	},
}

dap.adapters.gdb = {
	id = "gdb",
	type = "executable",
	command = "gdb",
	args = { "--quiet", "--interpreter=dap" },
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python", -- Changed from "py" to "python"
	callback = function()
		local dap = require("dap-python") -- Added 'local'
		vim.keymap.set("n", "<leader>dn", dap.test_method, { desc = "Python: Test Method" })
		vim.keymap.set("n", "<leader>df", dap.test_class, { desc = "Python: Test Class" })
		vim.keymap.set("n", "<leader>ds", dap.debug_selection, { desc = "Python: Debug Selection" })
	end,
})
