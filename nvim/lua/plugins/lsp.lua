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

local servers =
	{ "clangd", "rust_analyzer", "gopls", "lua_ls", "terraformls", "html", "nixd", "ocamllsp", "hls", "zls", "pyright" }
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
})
