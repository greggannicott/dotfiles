require("nvim-devdocs").setup({
	dir_path = vim.fn.stdpath("data") .. "/devdocs", -- installation directory
	telescope = {}, -- passed to the telescope picker
	telescope_alt = { -- when searching globally without preview
		layout_config = {
			width = 75,
		},
	},
	float_win = { -- passed to nvim_open_win(), see :h api-floatwin
		relative = "editor",
		height = 25,
		width = 100,
		border = "rounded",
	},
	wrap = false, -- text wrap
	ensure_installed = {}, -- get automatically installed
})
