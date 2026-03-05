return{
 'miferco97/kommentary',
 config=function()
   vim.g.kommentary_create_default_mappings = false
   vim.api.nvim_set_keymap("n", "gcc", "<Plug>kommentary_line_default", {})
   vim.api.nvim_set_keymap("v", "gc", "<Plug>kommentary_visual_singles<C-c>", {})
   vim.api.nvim_set_keymap("v", "ga", "<Plug>kommentary_visual_default<C-c>", {})
 end
}
