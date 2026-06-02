-- Conform config
local slow_format_filetypes = { scala = true }
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
