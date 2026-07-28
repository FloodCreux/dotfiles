-- Conform config
local slow_format_filetypes = { scala = true }

-- JS/TS-family filetypes are formatted via a dedicated `BufWritePre` autocmd
-- (see below) so we can deterministically order: organize imports -> ESLint
-- fix -> Prettier. They are excluded from conform's generic `format_on_save`
-- to avoid double-formatting.
local js_ts_filetypes = {
	javascript = true,
	javascriptreact = true,
	["javascript.jsx"] = true,
	typescript = true,
	typescriptreact = true,
	["typescript.tsx"] = true,
}

require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		-- Disable format_on_save for languages that don't have a well
		-- standardized coding style. Filetypes in `slow_format_filetypes`
		-- are handled by `format_after_save` instead.
		local disable_filetypes = { c = true, cpp = true }
		if disable_filetypes[vim.bo[bufnr].filetype] then
			return false
		end
		if slow_format_filetypes[vim.bo[bufnr].filetype] then
			return false
		end
		-- JS/TS handled by the dedicated BufWritePre orchestration below.
		if js_ts_filetypes[vim.bo[bufnr].filetype] then
			return false
		end
		return {
			timeout_ms = 500,
			lsp_fallback = true,
		}
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		python = {
			-- "isort",
			-- "black",
			-- "ruff",
			"ruff_fix",
			"ruff_organize_imports",
			"ruff_format",
		},
		javascript = { "prettier" },
		cs = { "csharpier" },
		xml = { "xmllint" },
		markdown = { "prettier" },
		nix = { "nixfmt" },
		ocaml = { "ocamlformat" },
		odin = { "odinfmt" },
		tf = { "terraform_fmt" },
		terraform = { "terraform_fmt" },
		typescript = { "prettier" },
		haskell = { "fourmolu" },
		zig = { "zigfmt" },
	},
	format_after_save = function(bufnr)
		if not slow_format_filetypes[vim.bo[bufnr].filetype] then
			return
		end
		return { lsp_fallback = true }
	end,
	formatters = {
		csharpier = {
			command = "csharpier",
			args = { "--write-stdout" },
		},
		odinfmt = {
			command = "odinfmt",
			args = { "-stdin" },
			stdin = true,
		},
	},
})

-- JS/TS save-time orchestration.
--
-- Runs synchronously on `BufWritePre` in a deterministic order so the tools
-- never fight each other:
--   1. ts_ls `source.organizeImports` (sort + remove unused imports)
--   2. ESLint `LspEslintFixAll` (rule autofixes)
--   3. Prettier (formatting, via conform)
--
-- Each step is gated on the relevant LSP client actually being attached, so it
-- is a no-op for stray JS/TS buffers opened outside a real project.
local function client_attached(bufnr, name)
	return #vim.lsp.get_clients({ bufnr = bufnr, name = name }) > 0
end

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("js_ts_format_on_save", { clear = true }),
	callback = function(args)
		local bufnr = args.buf
		if not js_ts_filetypes[vim.bo[bufnr].filetype] then
			return
		end

		-- 1. Organize imports via ts_ls (synchronous so it completes first).
		-- if client_attached(bufnr, "ts_ls") then
		-- 	-- pcall(vim.cmd, "LspTypescriptOrganizeImports")
		-- 	pcall(vim.lsp.buf.code_action, {
		-- 		context = { only = { "source.organizeImports" }, diagnostics = {} },
		-- 		apply = true,
		-- 	})
		-- end

		-- 2. ESLint autofixes. `LspEslintFixAll` uses `request_sync`, so the
		--    buffer is fully fixed before Prettier runs.
		if client_attached(bufnr, "eslint") then
			pcall(vim.cmd, "LspEslintFixAll")
		end

		-- 3. Prettier formatting (never fall back to an LSP formatter).
		require("conform").format({
			bufnr = bufnr,
			formatters = { "prettier" },
			timeout_ms = 1000,
			lsp_format = "never",
		})
	end,
})
