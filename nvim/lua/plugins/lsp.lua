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
		if vim.lsp.buf.format then
			vim.lsp.buf.format()
		elseif vim.lsp.buf.formatting then
			vim.lsp.buf.formatting()
		end
	end, { desc = "Format current buffer with LSP" })
end

local debuggers = { "debugpy" }

local all_tools = {}
for _, v in ipairs(debuggers) do
	table.insert(all_tools, v)
end

local servers = {
	"clangd",
	"rust_analyzer",
	"gopls",
	"lua_ls",
	"terraformls",
	"html",
	"nixd",
	"ocamllsp",
	"hls",
	"zls",
	"pyright",
	"csharp_ls",
	"ts_ls",
	"helm_ls",
}
for _, v in ipairs(servers) do
	table.insert(all_tools, v)
end

require("mason").setup({
	ensure_installed = all_tools,
})

vim.lsp.enable(servers)

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local function get_python_path(workspace)
	local uv_python = vim.fn.system("cd " .. workspace .. " && uv run which python 2>/dev/null")
	if vim.v.shell_error == 0 then
		return vim.trim(uv_python)
	end
	return vim.fn.exepath("python3") or vim.fn.exepath("python")
end

for _, lsp in ipairs(servers) do
	if lsp == "pyright" then
		vim.lsp.config(lsp, {
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
					},
				},
			},
			on_new_config = function(config, root_dir)
				config.settings.python.pythonPath = get_python_path(root_dir)
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "sh",
	callback = function()
		vim.lsp.start({
			name = "bash-language-server",
			cmd = { "bash-language-server", "start" },
		})
	end,
})

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
	"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
	"--razorSourceGenerator=" .. vim.fs.joinpath(rzls_base_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
	"--razorDesignTimePath="
		.. vim.fs.joinpath(rzls_base_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets"),
}

require("roslyn").setup({
	cmd = cmd,
	config = {
		ft = { "cs", "razor" },
		dependencies = {
			{
				-- By loading as a dependencies, we ensure that we are available to set
				-- the handlers for Roslyn.
				"tris203/rzls.nvim",
				config = true,
			},
		},
		config = function()
			-- Use one of the methods in the Integration section to compose the command.
			local roslyn_cmd = {}

			vim.lsp.config("roslyn", {
				cmd = roslyn_cmd,
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
			})
			vim.lsp.enable("roslyn")
		end,
		init = function()
			-- We add the Razor file types before the plugin loads.
			vim.filetype.add({
				extension = {
					razor = "razor",
					cshtml = "razor",
				},
			})
		end,
		handlers = require("rzls.roslyn_handlers"),
	},
})
