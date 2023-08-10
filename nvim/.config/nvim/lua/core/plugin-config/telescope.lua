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
})

-- Enable telescope fzf native, if installed
pcall(telescope.load_extension, "fzf")

-- Define keymappings to display presets
wk.register({
	["?"] = { require("telescope.builtin").oldfiles, "Find recently opened files" },
	["/"] = { require("telescope.builtin").current_buffer_fuzzy_find, "Fuzzily search in current buffer" },
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
		r = { require("telescope.builtin").lsp_references, "Search References" },
		s = { require("telescope.builtin").grep_string, "Grep String Under Cursor" },
		t = { require("telescope.builtin").tagstack, "Search Tagstack" },
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
