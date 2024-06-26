local wk = require("which-key")
local trouble = require("trouble.providers.telescope")
local telescope = require("telescope")
local actions = require("telescope.actions")
local lga_actions = require("telescope-live-grep-args.actions")
local harpoon = require("harpoon")
telescope.setup({
	defaults = {
		path_display = { "truncate" },
		mappings = {
			i = {
				["<c-t>"] = trouble.open_with_trouble,
				["<c-j>"] = actions.move_selection_next,
				["<c-k>"] = actions.move_selection_previous,
				["<c-p>"] = actions.move_selection_previous,
				["<c-n>"] = actions.move_selection_next,
			},
			n = {
				["<c-t>"] = trouble.open_with_trouble,
				["<c-j>"] = actions.move_selection_next,
				["<c-k>"] = actions.move_selection_previous,
				["<c-p>"] = actions.move_selection_previous,
				["<c-n>"] = actions.move_selection_next,
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
		live_grep_args = {
			auto_quoting = true, -- enable/disable auto-quoting
			-- define mappings, e.g.
			mappings = { -- extend mappings
				i = {
					["<C-i>"] = lga_actions.quote_prompt(),
				},
			},
		},
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
require("telescope").load_extension("noice")
require("telescope").load_extension("live_grep_args")

-- Harpoon integration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
	local file_paths = {}
	for _, item in ipairs(harpoon_files.items) do
		table.insert(file_paths, item.value)
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = require("telescope.finders").new_table({
				results = file_paths,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
		})
		:find()
end

-- Define keymappings to display presets
wk.register({
	["?"] = { require("telescope.builtin").oldfiles, "Find recently opened files" },
	["/"] = {
		function()
			require("telescope.builtin").current_buffer_fuzzy_find({
				sorting_strategy = "ascending",
				-- sort by line number (via https://github.com/nvim-telescope/telescope.nvim/issues/1080#issuecomment-1592392087)
				tiebreak = function(entry1, entry2, prompt)
					local start_pos1, _ = entry1.ordinal:find(prompt)
					if start_pos1 then
						local start_pos2, _ = entry2.ordinal:find(prompt)
						if start_pos2 then
							return start_pos1 < start_pos2
						end
					end
					return false
				end,
			})
		end,
		"Find in current buffer",
	},
	["<space>"] = { require("telescope.builtin").resume, "Re-open Telescope" },
	s = {
		name = "Search",
		b = { require("telescope.builtin").buffers, "Search existing Buffers" },
		c = { require("telescope.builtin").commands, "Search Commands" },
		C = { require("telescope.builtin").command_history, "Search Command History" },
		d = { require("telescope.builtin").diagnostics, "Search Diagnostics" },
		f = { require("telescope.builtin").find_files, "Search git Files" },
		g = { require("telescope").extensions.live_grep_args.live_grep_args, "Search using Grep" },
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
		u = { require("telescope").extensions.undo.undo, "Search Undo History" },
		v = { require("telescope.builtin").vim_options, "Search Vim Options" },
		x = {
			function()
				toggle_telescope(harpoon:list())
			end,
			"Search Harpoon",
		},
		Y = { require("telescope.builtin").lsp_dynamic_workspace_symbols, "Search Workspace Symbols" },
		y = { require("telescope.builtin").lsp_document_symbols, "Search Document Symbols" },
	},
}, { prefix = "<leader>" })

vim.keymap.set("n", "<C-p>", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").git_files({
		winblend = 10,
		previewer = true,
		prompt_title = "Find files...",
		sorting_strategy = "ascending",
		layout_config = {
			prompt_position = "top",
			width = 200,
		},
	})
end, { desc = "Find files" })
