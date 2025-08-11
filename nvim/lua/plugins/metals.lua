local metals_config = require("metals").bare_config()
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require("cmp_nvim_lsp").default_capabilities()
--
metals_config.capabilities = capabilities
metals_config.on_attach = function(client, bufnr)
	require("metals").setup_dap()
end

metals_config.settings = {
	metalsBinaryPath = "metals",
	autoImportBuild = "off",
	defaultBspToBuildTool = true,
	showImplicitArguments = true,
	showImplicitConversionsAndClasses = true,
	showInferredType = true,
	superMethodLensesEnabled = true,
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
}

local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "scala", "sbt", "java" },
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
