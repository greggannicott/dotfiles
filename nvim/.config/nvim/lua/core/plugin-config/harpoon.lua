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
		"<leader>1",
		function()
			harpoon:list():select(1)
		end,
		desc = "Open Harpoon 1",
	},
	{
		"<leader>2",
		function()
			harpoon:list():select(2)
		end,
		desc = "Open Harpoon 2",
	},
	{
		"<leader>3",
		function()
			harpoon:list():select(3)
		end,
		desc = "Open Harpoon 3",
	},
	{
		"<leader>4",
		function()
			harpoon:list():select(4)
		end,
		desc = "Open Harpoon 4",
	},
	{
		"<leader>5",
		function()
			harpoon:list():select(5)
		end,
		desc = "Open Harpoon 5",
	},
	{
		"<leader>6",
		function()
			harpoon:list():select(6)
		end,
		desc = "Open Harpoon 6",
	},
	{
		"<leader>7",
		function()
			harpoon:list():select(7)
		end,
		desc = "Open Harpoon 7",
	},
	{
		"<leader>8",
		function()
			harpoon:list():select(8)
		end,
		desc = "Open Harpoon 8",
	},
	{
		"<leader>9",
		function()
			harpoon:list():select(9)
		end,
		desc = "Open Harpoon 9",
	},
})
