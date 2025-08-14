---@brief
---
--- https://github.com/ocaml/ocaml-lsp
---
--- `ocaml-lsp` can be installed as described in [installation guide](https://github.com/ocaml/ocaml-lsp#installation).
---
--- To install the lsp server in a particular opam switch:
--- ```sh
--- opam install ocaml-lsp-server
--- ```

local util = require("utils")

local language_id_of = {
	menhir = "ocaml.menhir",
	ocaml = "ocaml",
	ocamlinterface = "ocaml.interface",
	ocamllex = "ocaml.ocamllex",
	reason = "reason",
	dune = "dune",
}

local get_language_id = function(_, ftype)
	return language_id_of[ftype]
end

return {
	cmd = { "ocamllsp" },
	filetypes = { "ocaml", "menhir", "ocamlinterface", "ocamllex", "reason", "dune" },
	capabilities = {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
	},
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local root =
			util.root_pattern("*.opam", "esy.json", "package.json", ".git", "dune-project", "dune-workspace")(fname)

		-- Fallback to current file's directory if no root pattern found
		if not root then
			root = vim.fn.fnamemodify(fname, ":h")
		end

		on_dir(root)
	end,
	get_language_id = get_language_id,
}
