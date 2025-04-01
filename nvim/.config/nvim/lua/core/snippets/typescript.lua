local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s({ trig = "cl", name = "Console Log" }, fmt("console.log({});", i(1))),
	s({
		trig = "clv",
		name = "Console Log with Variable",
		dscr = { "Inserts a console.log which has a string value that matches the name of a variable." },
	}, fmt("console.log('{}',{});", { i(1), rep(1) })),
	s({
		trig = "clvj",
		name = "Console Log with JSON Output",
		dscr = {
			"Inserts a console.log which has a string value that matches the variable name, and the output uses JSON.stringify.",
		},
	}, fmt("console.log('{}', JSON.stringify({}, null, 2));", { i(1), rep(1) })),
	s({ trig = "ct", name = "Console Table" }, fmt("console.table({});", i(1))),
	s({ trig = "ctr", name = "Console Trace" }, fmt("console.trace({});", i(1))),
	s(
		{ trig = "mockservice", name = "mock service", dscr = { "mocks an angular service using jasmine." } },
		fmt("const mock{} = jasmine.createSpyObj<{}>('{}', [{}])", { i(1), rep(1), rep(1), i(2) })
	),
	s(
		{ trig = "mockprovider", name = "insert mock provider" },
		fmt("{{ provide: {}, useValue: mock{}}}", { i(1), rep(1) })
	),
}
