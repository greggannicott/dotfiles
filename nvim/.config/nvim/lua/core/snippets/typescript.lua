local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s({trig="cl", name="Console Log"},
    fmt("console.log({});", i(1))
  ),
  s({trig="clv", name="Console Log with Variable", dscr={"Inserts a console.log which has a string value that matches the name of a variable."}},
    fmt("console.log('{}',{});", {i(1), rep(1)})
  ),
  s({trig="ct", name="Console Table"},
    fmt("console.table({});", i(1))
  ),
  s({trig="ctr", name="Console Trace"},
    fmt("console.trace({});", i(1))
  ),
}
