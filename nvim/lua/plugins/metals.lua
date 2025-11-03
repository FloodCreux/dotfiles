local utils = require("utils")
local map = utils.map

local metals_config = require("metals").bare_config()
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require("cmp_nvim_lsp").default_capabilities()

metals_config.init_options = {
	isHttpEnabled = true,
	compilerOptions = {
		snippetAutoIndent = false,
	},
}

local function metals_keymaps(bufnr)
	local opts = { buffer = bufnr, silent = true }
	local dap = require("dap")

	-- Build commands
	map("n", "<leader>mi", "<cmd>MetalsInfo<cr>", opts)
	map("n", "<leader>mc", "<cmd>MetalsBuildConnect<cr>", opts)
	map("n", "<leader>mC", "<cmd>MetalsBuildRestart<cr>", opts)
	map("n", "<leader>mb", "<cmd>MetalsBuildImport<cr>", opts)

	-- Compile
	map("n", "<leader>mcc", "<cmd>MetalsCompileCascade<cr>", opts)
	map("n", "<leader>mca", "<cmd>MetalsCompileCancel<cr>", opts)

	-- Code actions
	map("v", "<leader>mo", "<esc><cmd>MetalsOrganizeImports<cr>", opts)
	map("n", "<leader>mo", "<cmd>MetalsOrganizeImports<cr>", opts)

	-- New file from template
	map("n", "<leader>mn", "<cmd>MetalsNewScalaFile<cr>", opts)

	-- Test commands (if using Test Explorer)
	map("n", "<leader>mdc", dap.continue, opts)
	map("n", "<leader>mdr", dap.run_to_cursor, opts)
	-- map("n", "<leader>mdt", require("metals").debug_test, opts)

	-- Show implicit arguments/conversions at cursor
	map("n", "K", function()
		vim.lsp.buf.hover()
		-- Metals adds implicit info to hove
	end, opts)
end

metals_config.capabilities = capabilities
metals_config.on_attach = function(_, bufnr)
	metals_keymaps(bufnr)
	require("metals").setup_dap()
end

metals_config.settings = {
	metalsBinaryPath = "metals",
	autoImportBuild = "all",
	defaultBspToBuildTool = true,
	showImplicitArguments = true,
	showImplicitConversionsAndClasses = true,
	showInferredType = true,
	superMethodLensesEnabled = true,
	enableSemanticHighlighting = false,
	excludedPackages = {
		"akka.actor.typed.javadsl",
		"com.github.swagger.akka.javadsl",
	},
	serverProperties = {
		"-Xmx2G",
		"-XX:+UseZGC",
		"-XX:ZUncommitDelay=30",
		"-XX:ZCollectionInterval=5",
		"-XX:+IgnoreUnrecognizedVMOptions",
	},
	serverVersion = "latest.release",
	testUserInterface = "Test Exploror",
}

metals_config.handlers = {
	["metals/status"] = function(_, status, _)
		vim.g.metals_status = status.text
	end,
}

local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "scala", "sbt", "java", "mill" },
	callback = function()
		require("metals").initialize_or_attach(metals_config)
	end,
	group = nvim_metals_group,
})

-- Debug settings
local dap = require("dap")
dap.configurations.scala = {
	{
		type = "scala",
		request = "launch",
		name = "RunOrTest",
		metals = {
			runType = "runOrTestFile",
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
