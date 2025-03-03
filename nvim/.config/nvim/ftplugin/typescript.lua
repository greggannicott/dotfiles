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
	-- Insert a 't' as us capturing the t press means it doesn't happen naturally.
	vim.api.nvim_feedkeys("t", "n", true)

	-- Find out whether the preceding word is `awai`.
	local cursor_position = vim.api.nvim_win_get_cursor(0)
	local current_row = cursor_position[1]
	local current_col = cursor_position[2]
	local preceding_text =
		vim.api.nvim_buf_get_text(0, current_row - 1, current_col - 4, current_row - 1, current_col, {})[1]
	if preceding_text ~= "awai" then
		return
	end

	-- Find parent function statement
	local current_node = vim.treesitter.get_node()
	local nearest_function_node = find_ancestor(current_node,
		{ "arrow_function", "function_declaration", "method_definition" })
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
vim.keymap.set("i", "t", add_async, { buffer = true })

-- Used when you wish to debug. Introduce it and then whenever you want to reload this file you can use the keymapping specified.
--vim.keymap.set("n", "<leader>rr", "<cmd>so ~/.config/nvim/ftplugin/typescript.lua<cr>")
