return {
 'Civitasv/cmake-tools.nvim',
 config=function()
  vim.keymap.set('n','<leader>cg',vim.cmd('CMakeGenerate -D CMAKE_CXX_FLAGS=-std=c++17'))

--nnoremap <leader>cg :CMakeGenerate -D CMAKE_CXX_FLAGS=-std=c++17<CR>
--nnoremap <leader>cb :CMakeBuild<CR>
--nnoremap <leader>cr :CMakeRun<CR>
--nnoremap <leader>cc :CMakeStop<CR>

 end
}
