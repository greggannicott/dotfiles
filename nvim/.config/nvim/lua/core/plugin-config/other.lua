local wk = require('which-key')
require("other-nvim").setup({
    mappings = {
        -- builtin mappings
        "angular",
    },
    style = {
        -- How the plugin paints its window borders
        -- Allowed values are none, single, double, rounded, solid and shadow
        border = "solid",

        -- Column seperator for the window
        seperator = "|",

	-- width of the window in percent. e.g. 0.5 is 50%, 1.0 is 100%
	width = 0.7,

	-- min height in rows.
	-- when more columns are needed this value is extended automatically
	minHeight = 2
    },
})

wk.register({
  a = {
    name = "Angular",
    c = { '<cmd>:Other component<cr>', 'Open Component'},
    C = { '<cmd>:OtherVSplit component<cr>', 'Open Component (vertical split)'},
    h = { '<cmd>:Other html<cr>', 'Open HTML'},
    H = { '<cmd>:OtherVSplit html<cr>', 'Open HTML (vertical split)'},
    s = { '<cmd>:Other service<cr>', 'Open Service'},
    S = { '<cmd>:OtherVSplit service<cr>', 'Open Service (vertical split)'},
    t = { '<cmd>:Other test<cr>', 'Open Test'},
    T = { '<cmd>:OtherVSplit test<cr>', 'Open Test (vertical split)'},
    y = { '<cmd>:Other scss<cr>', 'Open SCSS'},
    Y = { '<cmd>:OtherVSplit scss<cr>', 'Open SCSS (vertical split)'},
  }
}, { prefix = '<leader>'})
