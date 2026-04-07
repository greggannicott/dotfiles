local dap = require("dap")
local dapgo = require("dap-go")
local dapview = require("dap-view")

-- Initialize dap-go with default settings
dapgo.setup()

-- Key mappings for debugging
local wk = require("which-key")

wk.add({
	{ "<leader>d", group = "Debug" },
	{
		"<leader>db",
		function()
			dap.toggle_breakpoint()
		end,
		desc = "Toggle Breakpoint",
	},
	{
		"<leader>dB",
		function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end,
		desc = "Conditional Breakpoint",
	},
	{
		"<leader>dc",
		function()
			dap.continue()
		end,
		desc = "Continue",
	},
	{
		"<leader>di",
		function()
			dap.step_into()
		end,
		desc = "Step Into",
	},
	{
		"<leader>do",
		function()
			dap.step_over()
		end,
		desc = "Step Over",
	},
	{
		"<leader>dO",
		function()
			dap.step_out()
		end,
		desc = "Step Out",
	},
	{
		"<leader>dr",
		function()
			dap.repl.open()
		end,
		desc = "Open REPL",
	},
	{
		"<leader>dl",
		function()
			dap.run_last()
		end,
		desc = "Run Last",
	},
	{
		"<leader>dt",
		function()
			dapgo.debug_test()
		end,
		desc = "Debug Test (at cursor)",
	},
	{
		"<leader>dT",
		function()
			dapgo.debug_last_test()
		end,
		desc = "Debug Last Test",
	},
	{
		"<leader>dx",
		function()
			dap.terminate()
		end,
		desc = "Terminate",
	},
	{
		"<leader>du",
		function()
			dap.up()
		end,
		desc = "Up Stack Frame",
	},
	{
		"<leader>dd",
		function()
			dap.down()
		end,
		desc = "Down Stack Frame",
	},
	{
		"<leader>dv",
		dapview.toggle,
		desc = "Toggle DAP View",
	},
	{
		"<leader>dw",
		dapview.add_expr,
		desc = "Watch Expression",
	},
}, { mode = "n" })

-- Signs for breakpoints
vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "⚫", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "➡️", texthl = "DapStopped", linehl = "DapStopped", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint", linehl = "", numhl = "" })
