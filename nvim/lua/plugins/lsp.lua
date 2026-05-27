-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	nmap("<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

-- Mason packages (debuggers, formatters, linters) — these are *Mason package
-- IDs*, not LSP server names. LSP servers are handled separately below via
-- `vim.lsp.enable`.
local mason_packages = {
	"debugpy",
	"js-debug-adapter",
	"prettier",
}

require("mason").setup({
	ensure_installed = mason_packages,
})

local servers = {
	"bashls",
	"c3_lsp",
	"clangd",
	"rust_analyzer",
	"gopls",
	"lua_ls",
	"terraformls",
	"html",
	"nixd",
	"hls",
	"zls",
	"ty",
	"csharp_ls",
	"ts_ls",
	"helm_ls",
	"eslint",
	"jsonls",
	"tailwindcss",
	"ruff",
}

vim.lsp.enable(servers)
vim.lsp.enable("ocamllsp")

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

for _, lsp in ipairs(servers) do
	if lsp == "ty" then
		-- Optional: Only required if you need to update the language server settings
		vim.lsp.config("ty", {
			settings = {
				ty = {
					-- ty language server settings go here
				},
			},
		})

		-- Required: Enable the language server
		vim.lsp.enable("ty")
	elseif lsp == "ruff" then
		vim.lsp.config(lsp, {
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				client.server_capabilities.hoverProvider = false
				on_attach(client, bufnr)
			end,
		})
	elseif lsp == "helm_ls" then
		vim.lsp.config(lsp, {
			on_attach = on_attach,
			capabilities = vim.tbl_deep_extend("force", capabilities, {
				workspace = {
					didChangeWatchedFiles = {
						dynamicRegistration = true,
					},
				},
			}),
			cmd = { "helm_ls", "serve" },
			filetypes = { "helm", "yaml.helm-values" },
			root_markers = { "Chart.yaml" },
		})
	else
		vim.lsp.config(lsp, {
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end
end

vim.filetype.add({
	extension = {
		jsonl = "json",
	},
	pattern = {
		[".*/templates/.*%.yaml"] = "helm",
		[".*/templates/.*%.tpl"] = "helm",
	},
	filename = {
		["Chart.yaml"] = "yaml",
		["values.yaml"] = "yaml.helm-values",
	},
})

local roslyn_base_path = vim.fs.joinpath(vim.fn.stdpath("data"), "roslyn")
local rzls_base_path = vim.fs.joinpath(vim.fn.stdpath("data"), "rzls")

local cmd = {
	"dotnet",
	vim.fs.joinpath(roslyn_base_path, "Microsoft.CodeAnalysis.LanguageServer.dll"),
	"--stdio",
	"--logLevel=Information",
	"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
	"--razorSourceGenerator=" .. vim.fs.joinpath(rzls_base_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
	"--razorDesignTimePath="
		.. vim.fs.joinpath(rzls_base_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets"),
}

-- Register Razor filetypes before roslyn.nvim loads its handlers
vim.filetype.add({
	extension = {
		razor = "razor",
		cshtml = "razor",
	},
})

require("roslyn").setup({
	cmd = cmd,
	config = {
		handlers = require("rzls.roslyn_handlers"),
		settings = {
			["csharp|inlay_hints"] = {
				csharp_enable_inlay_hints_for_implicit_object_creation = true,
				csharp_enable_inlay_hints_for_implicit_variable_types = true,
				csharp_enable_inlay_hints_for_lambda_parameter_types = true,
				csharp_enable_inlay_hints_for_types = true,
				dotnet_enable_inlay_hints_for_indexer_parameters = true,
				dotnet_enable_inlay_hints_for_literal_parameters = true,
				dotnet_enable_inlay_hints_for_object_creation_parameters = true,
				dotnet_enable_inlay_hints_for_other_parameters = true,
				dotnet_enable_inlay_hints_for_parameters = true,
				dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
				dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
				dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
			},
			["csharp|code_lens"] = {
				dotnet_enable_references_code_lens = true,
			},
		},
	},
	filewatching = "roslyn",
})
