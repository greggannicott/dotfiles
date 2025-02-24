local wk = require("which-key")
local telescope = require("telescope")
local actions = require("telescope.actions")
local lga_actions = require("telescope-live-grep-args.actions")
telescope.setup({
	defaults = {
		path_display = { "truncate" },
		mappings = {
			i = {
				["<c-p>"] = actions.move_selection_previous,
				["<c-n>"] = actions.move_selection_next,
			},
			n = {
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
			vim_diff_opts = { ctxlen = 8 },
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

-- Define keymappings to display presets
wk.add({
	{
		"<leader>/",
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
		desc = "Find in current buffer",
	},
	{ "<leader><space>", require("telescope.builtin").resume, desc = "Re-open Telescope" },
	{ "<leader>?", require("telescope.builtin").oldfiles, desc = "Find recently opened files" },
	{ "<leader>s", group = "Search" },
	{ "<leader>sC", require("telescope.builtin").commands, desc = "Search Command History" },
	{
		"<leader>sH",
		function()
			local cursor_word = vim.fn.expand("<cword>")
			require("telescope.builtin").help_tags({
				default_text = cursor_word,
			})
		end,
		desc = "Search Help Under Cursor",
	},
	{ "<leader>sM", require("telescope.builtin").man_pages, desc = "Search Man Pages" },
	{ "<leader>sY", require("telescope.builtin").lsp_dynamic_workspace_symbols, desc = "Search Workspace Symbols" },
	{ "<leader>sb", require("telescope.builtin").buffers, desc = "Search existing Buffers" },
	{ "<leader>sc", require("telescope.builtin").commands, desc = "Search Commands" },
	{ "<leader>sd", require("telescope.builtin").diagnostics, desc = "Search Diagnostics" },
	{ "<leader>sf", require("telescope.builtin").find_files, desc = "Search Files" },
	{ "<leader>sg", require("telescope").extensions.live_grep_args.live_grep_args, desc = "Search using Grep" },
	{ "<leader>sh", require("telescope.builtin").help_tags, desc = "Search Help" },
	{ "<leader>sj", require("telescope.builtin").jumplist, desc = "Search Jumplist" },
	{ "<leader>sk", require("telescope.builtin").keymaps, desc = "Search Keymaps" },
	{ "<leader>sl", require("telescope.builtin").git_commits, desc = "Search Git Log" },
	{ "<leader>sm", require("telescope.builtin").marks, desc = "Search Marks" },
	{ "<leader>sr", require("telescope.builtin").lsp_references, desc = "Search References" },
	{ "<leader>ss", require("telescope.builtin").grep_string, desc = "Grep String Under Cursor" },
	{ "<leader>st", require("telescope.builtin").tagstack, desc = "Search Tagstack" },
	{ "<leader>su", require("telescope").extensions.undo.undo, desc = "Search Undo History" },
	{ "<leader>sv", require("telescope.builtin").vim_options, desc = "Search Vim Options" },
	{ "<leader>sy", require("telescope.builtin").lsp_document_symbols, desc = "Search Document Symbols" },
})

vim.keymap.set("n", "<C-p>", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").git_files({
		previewer = true,
		prompt_title = "Find files...",
		sorting_strategy = "ascending",
		layout_config = {
			prompt_position = "top",
			width = 200,
		},
	})
end, { desc = "Find files" })
