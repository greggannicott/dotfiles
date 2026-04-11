local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require("nvim-treesitter").setup({
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
		"angular",
	},

	-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
	auto_install = true,

	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<c-space>",
			node_incremental = "<c-space>",
			scope_incremental = "<c-s>",
			node_decremental = "<M-space>",
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				-- Enable treesitter highlighting and disable regex syntax
				pcall(vim.treesitter.start)
				-- Enable treesitter-based indentation
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		local ensureInstalled = {
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
			"angular",
		}

		local alreadyInstalled = require("nvim-treesitter.config").get_installed()
		local parsersToInstall = vim.iter(ensureInstalled)
			:filter(function(parser)
				return not vim.tbl_contains(alreadyInstalled, parser)
			end)
			:totable()
		require("nvim-treesitter").install(parsersToInstall)
	end,
	textobjects = {
		select = {
			enable = false,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				-- NOTE: As it stands, these are disabled in favour of mini.ai. See `enable = false` above.
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
				["]i"] = "@test.outer",
				["]a"] = "@parameter.inner",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]V"] = "@assignment.rhs",
				-- Requires jasmine-toggle.nvim plugin
				["]I"] = "@test.outer",
				["]A"] = "@parameter.inner",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[v"] = "@assignment.lhs",
				-- Requires jasmine-toggle.nvim plugin
				["[i"] = "@test.outer",
				["[a"] = "@parameter.inner",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[V"] = "@assignment.rhs",
				-- Requires jasmine-toggle.nvim plugin
				["[I"] = "@test.outer",
				["[A"] = "@parameter.inner",
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
