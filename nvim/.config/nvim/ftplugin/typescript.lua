--- @param node TSNode
--- @param types table
local function find_ancestor(node, types)
	if not node then
		return nil
	end
	if vim.tbl_contains(types, node:type()) then
		return node
	end
	return find_ancestor(node:parent(), types)
end

local function add_async()
	local cursor_position = vim.api.nvim_win_get_cursor(0)
	local current_row = cursor_position[1]
	local current_col = cursor_position[2]

	-- Insert the 't' character to replace the 't' which just acted on.
	-- Instead of feeding keys, directly insert 't' and update cursor position.
	-- This is to make it work normal mode via the command line and macros.
	vim.api.nvim_buf_set_text(0, current_row - 1, current_col, current_row - 1, current_col, { "t" })

	-- Move cursor after the inserted 't'
	vim.api.nvim_win_set_cursor(0, { current_row, current_col + 1 })

	-- If the cursor is at the start of the line, we can't insert an `async` keyword.
	if current_col < 4 then
		return
	end

	local preceding_text =
		vim.api.nvim_buf_get_text(0, current_row - 1, current_col - 4, current_row - 1, current_col, {})[1]
	if preceding_text ~= "awai" then
		return
	end

	-- Find parent function statement
	local current_node = vim.treesitter.get_node()
	local nearest_function_node =
		find_ancestor(current_node, { "arrow_function", "function_declaration", "method_definition" })
	if not nearest_function_node then
		return
	end

	-- Check if an await already exists. If it does, don't insert another.
	local func_start_row, func_start_col = nearest_function_node:start()
	local existing_text = vim.treesitter.get_node_text(nearest_function_node, 0, {})
	if vim.startswith(existing_text, "async") then
		return
	end

	-- Insert the "async"
	vim.api.nvim_buf_set_text(0, func_start_row, func_start_col, func_start_row, func_start_col, { "async " })
end

-- Trigger `add_async` when user presses "t". This will insert an `async` if the function requires due to the use of an `await`.
-- This has been disabled as you couldn't get it to work in all of the following scenarions. Only some:
-- - When normal mode is entered via the command line.
-- - When used as part of a macros called via command line.
-- - When used as part of a '.' repeat command.
-- vim.keymap.set("i", "t", add_async, { buffer = true })

-- Used when you wish to debug. Introduce it and then whenever you want to reload this file you can use the keymapping specified.
vim.keymap.set("n", "<leader>rr", "<cmd>so ~/.config/nvim/ftplugin/typescript.lua<cr>")
