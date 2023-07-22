-- Custom Surrounds/Wrappings
-- Note: for some reason you couldn't get these to work with the <leader> key and so you've used ',' instead.

-- Wrap console.log(*) around selected text.
vim.api.nvim_buf_set_keymap(0, 'v', ',cl', [[cconsole.log(<c-r>"<esc>]], { noremap = false })
