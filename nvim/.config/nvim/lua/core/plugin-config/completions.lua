-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})
local wk = require("which-key")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete({}),
		-- Use 'y' rather than 'enter' to confirm because.... Teej does.
		-- I don't actually know the reasoining behind it though.
		["<C-y>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		-- <c-l> will move you to the right of each of the expansion locations.
		-- <c-h> is similar, except moving you backwards.
		["<C-l>"] = cmp.mapping(function()
			if luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			end
		end, { "i", "s" }),
		["<C-h>"] = cmp.mapping(function()
			if luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer", keyword_length = 4 },
	},
	completion = {
		completeopt = "noselect",
	},
	preselect = cmp.PreselectMode.None,
})

-- `/` cmdline setup.
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline({
		["<C-j>"] = { c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }) },
		["<C-k>"] = { c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }) },
	}),
	sources = {
		{ name = "buffer" },
	},
})

-- `:` cmdline setup.
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline({
		["<C-j>"] = { c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }) },
		["<C-k>"] = { c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }) },
	}),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{
			name = "cmdline",
			option = {
				ignore_cmds = { "Man", "!" },
			},
		},
	}),
})

wk.add({
	{ "<leader>cC", "<cmd>Copilot disable<CR>", desc = "Disable Copilot" },
	{ "<leader>cc", "<cmd>Copilot enable<CR>", desc = "Enable Copilot" },
})
