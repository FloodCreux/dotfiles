local cmp = require("cmp")
local luasnip = require("luasnip")

local function is_picker_buffer()
	local buftype = vim.bo.buftype
	local filetype = vim.bo.filetype
	return buftype == "nofile" and (filetype:match("snacks") or filetype:match("picker") or vim.b.snacks_picker_open)
end

cmp.setup({
	enabled = function()
		local snacks_ok, snacks = pcall(require, "snacks")
		return not (snacks_ok and snacks.picker and is_picker_buffer())
	end,

	window = {
		completion = {
			autocomplete = false,
		},
	},

	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "neorg" },
	},
})
