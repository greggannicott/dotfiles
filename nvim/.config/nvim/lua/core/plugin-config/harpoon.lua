local harpoon = require("harpoon")
local wk = require("which-key")

harpoon:setup({
	settings = {
		save_on_toggle = true,
		sync_on_ui_close = false,
		key = function()
			return vim.loop.cwd()
		end,
	},
})

wk.add({
	{ "<leader>h", group = "Harpoon" },
	{
		"<leader>ha",
		function()
			harpoon:list():add()
		end,
		desc = "Add current file to Harpoon",
	},
	{
		"<leader>hh",
		function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end,
		desc = "Toggle Harpoon menu",
	},
	{
		"[[",
		function()
			harpoon:list():prev()
		end,
		desc = "Previous Harpoon buffer",
	},
	{
		"]]",
		function()
			harpoon:list():next()
		end,
		desc = "Next Harpoon buffer",
	},
})
