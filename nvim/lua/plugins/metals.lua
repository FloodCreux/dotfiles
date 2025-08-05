-- -- Scala nvim-metals config
local metals_config = require("metals").bare_config()
metals_config.capabilities = {} --require("cmp_nvim_lsp").default_capabilities()
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
--
-- metals_config.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
-- 	virtual_text = {
-- 		prefix = "",
-- 	},
-- })
--
-- -- without doing this, autocommands that deal with filetypes prohibit messages from being shown
-- vim.opt_global.shortmess:remove("F")
--
-- vim.cmd([[augroup lsp]])
-- vim.cmd([[autocmd!]])
-- vim.cmd([[autocmd FileType java,scala,sbt lua require('metals').initialize_or_attach(metals_config)]])
-- vim.cmd([[augroup end]])
--
-- metals_config.on_attach = function(client, bufnr)
-- 	require("metals").setup_dap()
-- 	return metals_config
-- end
-- local metals_config = require("metals").bare_config()
-- metals_config.init_options.statusBarProvider = "on"
-- metals_config.settings = {
-- 	showImplicitArguments = true,
-- 	excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
-- }

local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	-- NOTE: You may or may not want java included here. You will need it if you
	-- want basic Java support but it may also conflict if you are using
	-- something like nvim-jdtls which also works on a java filetype autocmd.
	pattern = { "scala", "sbt", "java" },
	callback = function()
		require("metals").initialize_or_attach(metals_config)
	end,
	group = nvim_metals_group,
})

-- Debug settings
-- local dap = require("dap")
-- dap.configurations.scala = {
-- 	{
-- 		type = "scala",
-- 		request = "launch",
-- 		name = "RunOrTest",
-- 		metals = {
-- 			runType = "runOrTestFile",
-- 			--args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
-- 			args = { "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED" },
-- 		},
-- 	},
-- 	{
-- 		type = "scala",
-- 		request = "launch",
-- 		name = "Test Target",
-- 		metals = {
-- 			runType = "testTarget",
-- 		},
-- 	},
-- }
