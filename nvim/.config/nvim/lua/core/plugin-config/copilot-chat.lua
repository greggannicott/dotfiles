local prompts = require("CopilotChat.config.prompts")
local select = require("CopilotChat.select")
local wk = require("which-key")
require("CopilotChat").setup({

	-- Shared config starts here (can be passed to functions at runtime and configured via setup function)

	system_prompt = prompts.COPILOT_INSTRUCTIONS.system_prompt, -- System prompt to use (can be specified manually in prompt via /).

	model = "claude-3.7-sonnet", -- Default model to use, see ':CopilotChatModels' for available models (can be specified manually in prompt via $).
	agent = "copilot", -- Default agent to use, see ':CopilotChatAgents' for available agents (can be specified manually in prompt via @).
	context = nil, -- Default context or array of contexts to use (can be specified manually in prompt via #).
	sticky = nil, -- Default sticky prompt or array of sticky prompts to use at start of every new chat.

	temperature = 0.1, -- GPT result temperature
	headless = false, -- Do not write to chat buffer and use history(useful for using callback for custom processing)
	callback = nil, -- Callback to use when ask response is received

	-- default selection
	selection = function(source)
		return select.visual(source) or select.buffer(source)
	end,

	-- default window options
	window = {
		layout = "vertical", -- 'vertical', 'horizontal', 'float', 'replace'
		width = 0.5, -- fractional width of parent, or absolute width in columns when > 1
		height = 0.5, -- fractional height of parent, or absolute height in rows when > 1
		-- Options below only apply to floating windows
		relative = "editor", -- 'editor', 'win', 'cursor', 'mouse'
		border = "single", -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
		row = nil, -- row position of the window, default is centered
		col = nil, -- column position of the window, default is centered
		title = "Copilot Chat", -- title of chat window
		footer = nil, -- footer of chat window
		zindex = 1, -- determines if window is on top or below other floating windows
	},

	show_help = true, -- Shows help message as virtual lines when waiting for user input
	show_folds = true, -- Shows folds for sections in chat
	highlight_selection = true, -- Highlight selection
	highlight_headers = true, -- Highlight headers in chat, disable if using markdown renderers (like render-markdown.nvim)
	auto_follow_cursor = true, -- Auto-follow cursor in chat
	auto_insert_mode = false, -- Automatically enter insert mode when opening window and on new prompt
	insert_at_end = false, -- Move cursor to end of buffer when inserting text
	clear_chat_on_new_prompt = false, -- Clears chat on every new prompt

	-- Static config starts here (can be configured only via setup function)

	debug = debug, -- Enable debug logging (same as 'log_level = 'debug')
	log_level = "info", -- Log level to use, 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
	proxy = nil, -- [protocol://]host[:port] Use this proxy
	allow_insecure = false, -- Allow insecure server connections

	chat_autocomplete = true, -- Enable chat autocompletion (when disabled, requires manual `mappings.complete` trigger)
	history_path = vim.fn.stdpath("data") .. "/copilotchat_history", -- Default path to stored history

	question_header = "# User ", -- Header to use for user questions
	answer_header = "# Copilot ", -- Header to use for AI answers
	error_header = "# Error ", -- Header to use for errors
	separator = "───", -- Separator to use in chat

	-- default contexts
	contexts = {
		buffer = {
			-- see config.lua for implementation
		},
		buffers = {
			-- see config.lua for implementation
		},
		file = {
			-- see config.lua for implementation
		},
		files = {
			-- see config.lua for implementation
		},
		git = {
			-- see config.lua for implementation
		},
		url = {
			-- see config.lua for implementation
		},
		register = {
			-- see config.lua for implementation
		},
		quickfix = {
			-- see config.lua for implementation
		},
	},

	-- default prompts
	prompts = {
		Explain = {
			prompt = "> /COPILOT_EXPLAIN\n\nWrite an explanation for the selected code as paragraphs of text.",
		},
		Review = {
			prompt = "> /COPILOT_REVIEW\n\nReview the selected code.",
			-- see config.lua for implementation
		},
		Fix = {
			prompt = "> /COPILOT_GENERATE\n\nThere is a problem in this code. Rewrite the code to show it with the bug fixed.",
		},
		Optimize = {
			prompt = "> /COPILOT_GENERATE\n\nOptimize the selected code to improve performance and readability.",
		},
		Docs = {
			prompt = "> /COPILOT_GENERATE\n\nPlease add documentation comments to the selected code.",
		},
		Tests = {
			prompt = "> /COPILOT_GENERATE\n\nPlease generate tests for my code.",
		},
		Commit = {
			prompt = "> #git:staged\n\nWrite commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit. Begin the title with the branch name followed by a colon, unless the branch is 'main'. Where appropriate, use markdown formatting.",
		},
	},

	-- default mappings
	mappings = {
		complete = {
			insert = "<Tab>",
		},
		close = {
			normal = "q",
			insert = "<C-c>",
		},
		reset = {
			normal = "<C-x>",
			insert = "<C-x>",
		},
		submit_prompt = {
			normal = "<CR>",
			insert = "<C-s>",
		},
		toggle_sticky = {
			detail = "Makes line under cursor sticky or deletes sticky line.",
			normal = "gr",
		},
		accept_diff = {
			normal = "<C-f>",
			insert = "<C-f>",
		},
		jump_to_diff = {
			normal = "gj",
		},
		quickfix_answers = {
			normal = "gqa",
		},
		quickfix_diffs = {
			normal = "gqd",
		},
		yank_diff = {
			normal = "gy",
			register = '"', -- Default register to use for yanking
		},
		show_diff = {
			normal = "gd",
			full_diff = true, -- Show full diff instead of unified diff when showing diff window
		},
		show_info = {
			normal = "gi",
		},
		show_context = {
			normal = "gc",
		},
		show_help = {
			normal = "gh",
		},
	},
})

wk.add({
	{ "<C-c>", "<cmd>CopilotChatToggle<CR>", desc = "Toggle Copilot Chat" },
	{ "<leader>cc", group = "Copilot" },
	{ "<leader>cc", group = "Copilot", mode = "v" },

	-- copilot.nvim
	{ "<leader>ccd", "<cmd>Copilot disable<CR>", desc = "Disable Copilot" },
	{ "<leader>cce", "<cmd>Copilot enable<CR>", desc = "Enable Copilot" },
	-- copilot-chat.nvim
	{ "<leader>ccc", "<cmd>CopilotChatOpen<CR>", desc = "Open Copilot Chat" },
	{ "<leader>ccc", "<cmd>CopilotChatOpen<CR>", desc = "Open Copilot Chat", mode = "v" },
	{ "<leader>cce", "<cmd>CopilotChatExplain<CR>", desc = "Open Copilot Chat (Explain Prompt)" },
	{ "<leader>cce", "<cmd>CopilotChatExplain<CR>", desc = "Open Copilot Chat (Explain Prompt)", mode = "v" },
	{ "<leader>ccf", "<cmd>CopilotChatFix<CR>", desc = "Open Copilot Chat (Fix Prompt)" },
	{ "<leader>ccf", "<cmd>CopilotChatFix<CR>", desc = "Open Copilot Chat (Fix Prompt)", mode = "v" },
	{ "<leader>cco", "<cmd>CopilotChatOptimize<CR>", desc = "Open Copilot Chat (Optimize Prompt)" },
	{ "<leader>cco", "<cmd>CopilotChatOptimize<CR>", desc = "Open Copilot Chat (Optimize Prompt)", mode = "v" },
	{ "<leader>ccr", "<cmd>CopilotChatReview<CR>", desc = "Open Copilot Chat (Review Prompt)" },
	{ "<leader>ccr", "<cmd>CopilotChatReview<CR>", desc = "Open Copilot Chat (Review Prompt)", mode = "v" },
	{ "<leader>ccs", "<cmd>CopilotChatCommit<CR>", desc = "Open Copilot Chat (Commit Prompt)" },
	{ "<leader>ccs", "<cmd>CopilotChatCommit<CR>", desc = "Open Copilot Chat (Commit Prompt)", mode = "v" },
})
