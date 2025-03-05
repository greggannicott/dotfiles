require("mini.surround").setup({
	-- Add custom surroundings to be used on top of builtin ones. For more
	-- information with examples, see `:h MiniSurround.config`.
	custom_surroundings = nil,

	-- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
	highlight_duration = 500,

	-- NOTE: The default mappings started with an "s", with the theory being "surround... x". However, this conflicts with vim's `s` command, so you have reverted to Tim Pope's surround mappings.
	-- Module mappings. use `''` (empty string) to disable one.
	mappings = {
		add = "ys", -- Add surrounding in Normal and Visual modes
		delete = "ds", -- Delete surrounding
		-- Mapping removed until I can find one I like. Default one started with `s` which messes with vim's actual `s`.
		find = "", -- Find surrounding (to the right)
		-- Mapping removed until I can find one I like. Default one started with `s` which messes with vim's actual `s`.
		find_left = "", -- Find surrounding (to the left)
		-- Mapping removed until I can find one I like. Default one started with `s` which messes with vim's actual `s`.
		highlight = "", -- Highlight surrounding
		replace = "cs", -- Replace surrounding
		-- Mapping removed until I can find one I like. Default one started with `s` which messes with vim's actual `s`.
		update_n_lines = "", -- Update `n_lines`

		suffix_last = "l", -- Suffix to search with "prev" method
		suffix_next = "n", -- Suffix to search with "next" method
	},

	-- Number of lines within which surrounding is searched
	n_lines = 20,

	-- Whether to respect selection type:
	-- - Place surroundings on separate lines in linewise mode.
	-- - Place surroundings on each line in blockwise mode.
	respect_selection_type = false,

	-- How to search for surrounding (first inside current line, then inside
	-- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
	-- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
	-- see `:h MiniSurround.config`.
	search_method = "cover",

	-- Whether to disable showing non-error feedback
	-- This also affects (purely informational) helper messages shown after
	-- idle time if user input is required.
	silent = false,
})
