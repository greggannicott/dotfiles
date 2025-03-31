local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require("nvim-treesitter.configs").setup({
	-- Add languages to be installed here that you want installed for treesitter
	ensure_installed = {
		"c",
		"cpp",
		"go",
		"lua",
		"python",
		"rust",
		"tsx",
		"typescript",
		"vimdoc",
		"vim",
		"html",
		"json",
		"jsdoc",
		"markdown",
		"scss",
		"yaml",
		"gitcommit",
		"diff",
		"git_rebase",
		"tmux",
	},

	-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
	auto_install = true,

	highlight = { enable = true },
	indent = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<c-space>",
			node_incremental = "<c-space>",
			scope_incremental = "<c-s>",
			node_decremental = "<M-space>",
		},
	},
	textobjects = {
		select = {
			enable = false,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				-- NOTE: As it stands, these are disabled in favour of mini.ai. See `enable` parameter above.
				["aa"] = "@attribute.outer",
				["ia"] = "@attribute.inner",
				["aP"] = "@parameter.outer",
				["iP"] = "@parameter.inner",
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["aC"] = "@comment.outer",
				["iC"] = "@comment.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]v"] = "@assignment.lhs",
				-- Requires jasmine-toggle.nvim plugin
				["]i"] = "@test.it.all",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]V"] = "@assignment.rhs",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[v"] = "@assignment.lhs",
				-- Requires jasmine-toggle.nvim plugin
				["[i"] = "@test.it.all",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[V"] = "@assignment.rhs",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>a"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>A"] = "@parameter.inner",
			},
		},
	},
})

-- Repeat movement with ; and ,
-- Commented out as it was interfering with the built in `;` functionality:
-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
