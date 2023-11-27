-- Desc: Vimspector config file

return {
	'puremourning/vimspector',
  config = function()
    --let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools', 'CodeLLDB' ]
    --let g:vimspector_enable_mappings = 'HUMAN'
    -- into lua config
    vim.g.vimspector_install_gadgets = { 'debugpy', 'vscode-cpptools', 'CodeLLDB' }
    vim.g.vimspector_enable_mappings = 'VISUAL_STUDIO'


    -- nmap <leader>bd :call vimspector#Launch()<CR>
    -- nmap <leader>dx :VimspectorReset<CR>
    -- nmap <leader>de :VimspectorEval
    -- nmap <leader>dw :VimspectorWatch
    -- nmap <leader>do :VimspectorShowOutput
    -- nmap <Leader>di <Plug>VimspectorBalloonEval
    -- xmap <Leader>di <Plug>VimspectorBalloonEval
    -- into lua config
    vim.api.nvim_set_keymap('n', '<leader>bd', ':call vimspector#Launch()<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>dx', ':VimspectorReset<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>de', ':VimspectorEval', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>dw', ':VimspectorWatch', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>do', ':VimspectorShowOutput', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>di', '<Plug>VimspectorBalloonEval', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('x', '<leader>di', '<Plug>VimspectorBalloonEval', { noremap = true, silent = true })

  end
}
