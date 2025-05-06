return {
  'akinsho/toggleterm.nvim', 
  version = "*", 
  config = function()
    require("toggleterm").setup{
    start_in_insert = true,
    persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
    close_on_exit = true -- close the terminal window when the process exits
    }
    function _G.set_terminal_keymaps()
    local opts = {noremap = true}
    vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', 'jj', [[<C-\><C-n>]], opts)
    end
    -- if you only want these mappings for toggle term use term://*toggleterm#* instead
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

    -- close the terminal window when the process exits
    vim.cmd('autocmd! TermClose term://* lua vim.cmd("stopinsert")')

    -- remap C-t to open a terminal window
    vim.api.nvim_set_keymap('n', '<C-t>', '<cmd>ToggleTerm<CR>', {noremap = true})
  end,
}

