local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		{ trig = "tl", name = "Tracer Log" },
		fmt('logging.Tracer.AtTraceLevel(logsettings.Verbose).Log("{}"{});', { i(1), i(2) })
	),
}
