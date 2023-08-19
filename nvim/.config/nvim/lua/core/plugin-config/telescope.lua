local wk = require("which-key")
local trouble = require("trouble.providers.telescope")
local telescope = require("telescope")
local actions = require("telescope.actions")
telescope.setup({
	defaults = {
		path_display = { "truncate" },
		mappings = {
			i = {
				["<c-t>"] = trouble.open_with_trouble,
				["<c-k>"] = actions.cycle_history_prev,
				["<c-j>"] = actions.cycle_history_next,
			},
			n = {
				["<c-t>"] = trouble.open_with_trouble,
				["<c-k>"] = actions.cycle_history_prev,
				["<c-j>"] = actions.cycle_history_next,
			},
		},
	},
	pickers = {
		lsp_references = {
			fname_width = 40,
			path_display = { "tail" },
		},
	},
	extensions = {
		undo = {
			use_delta = true,
			use_custom_command = nil, -- setting this implies `use_delta = false`. Accepted format is: { "bash", "-c", "echo '$DIFF' | delta" }
			side_by_side = true,
			diff_context_lines = vim.o.scrolloff,
			entry_format = "state #$ID, $STAT, $TIME",
			time_format = "",
			mappings = {
				i = {
					-- IMPORTANT: Note that telescope-undo must be available when telescope is configured if
					-- you want to replicate these defaults and use the following actions. This means
					-- installing as a dependency of telescope in it's `requirements` and loading this
					-- extension from there instead of having the separate plugin definition as outlined
					-- above.
					["<cr>"] = require("telescope-undo.actions").yank_additions,
					["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
					["<C-cr>"] = require("telescope-undo.actions").restore,
				},
			},
		},
	},
})

-- Enable telescope fzf native, if installed
pcall(telescope.load_extension, "fzf")
require("telescope").load_extension("undo")
require("telescope").load_extension("harpoon")

-- Define keymappings to display presets
wk.register({
	["?"] = { require("telescope.builtin").oldfiles, "Find recently opened files" },
	["/"] = { require("telescope.builtin").current_buffer_fuzzy_find, "Fuzzily search in current buffer" },
	["<space>"] = { require("telescope.builtin").resume, "Re-open Telescope" },
	s = {
		name = "Search",
		b = { require("telescope.builtin").buffers, "Search existing Buffers" },
		c = { require("telescope.builtin").commands, "Search Commands" },
		C = { require("telescope.builtin").command_history, "Search Command History" },
		d = { require("telescope.builtin").diagnostics, "Search Diagnostics" },
		f = { require("telescope.builtin").find_files, "Search git Files" },
		g = { require("telescope.builtin").live_grep, "Search using Grep" },
		G = {
			function()
				local glob_pattern = vim.fn.input("File Name (GLOB Pattern) > ")
				if glob_pattern == "" then
					return
				end
				require("telescope.builtin").live_grep({
					glob_pattern = glob_pattern,
				})
			end,
			"Search using Grep (Filter by File Name)",
		},
		h = { require("telescope.builtin").help_tags, "Search Help" },
		H = {
			function()
				local cursor_word = vim.fn.expand("<cword>")
				require("telescope.builtin").help_tags({
					default_text = cursor_word,
				})
			end,
			"Search Help Under Cursor",
		},
		j = { require("telescope.builtin").jumplist, "Search Jumplist" },
		k = { require("telescope.builtin").keymaps, "Search Keymaps" },
		m = { require("telescope.builtin").marks, "Search Marks" },
		M = { require("telescope.builtin").man_pages, "Search Man Pages" },
		r = { require("telescope.builtin").lsp_references, "Search References" },
		s = { require("telescope.builtin").grep_string, "Grep String Under Cursor" },
		t = { require("telescope.builtin").tagstack, "Search Tagstack" },
		u = { require("telescope.").extensions.undo.undo, "Search Undo History" },
		v = { require("telescope.builtin").vim_options, "Search Vim Options" },
		Y = { require("telescope.builtin").lsp_dynamic_workspace_symbols, "Search Workspace Symbols" },
		y = { require("telescope.builtin").lsp_document_symbols, "Search Document Symbols" },
	},
}, { prefix = "<leader>" })

vim.keymap.set("n", "<C-p>", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").git_files(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
		prompt_title = "Find files...",
		layout_config = {
			width = 200,
		},
	}))
end, { desc = "Find files" })
