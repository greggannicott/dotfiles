require("mini.operators").setup({
	-- Each entry configures one operator.
	-- `prefix` defines keys mapped during `setup()`: in Normal mode
	-- to operate on textobject and line, in Visual - on selection.

	-- Evaluate text and replace with output
	evaluate = {
		prefix = "g=",

		-- Function which does the evaluation
		func = nil,
	},

	-- Exchange text regions
	exchange = {
		prefix = "gx",

		-- Whether to reindent new text to match previous indent
		reindent_linewise = true,
	},

	-- Multiply (duplicate) text
	multiply = {
		prefix = "gm",

		-- Function which can modify text before multiplying
		func = nil,
	},

	-- Replace text with register
	-- NOTE: Disabled until you can find a mapping that doesn't clash with `gr` (ie. view referencs
	-- replace = {
	-- 	prefix = "gr",
	--
	-- 	-- Whether to reindent new text to match previous indent
	-- 	reindent_linewise = true,
	-- },
})
