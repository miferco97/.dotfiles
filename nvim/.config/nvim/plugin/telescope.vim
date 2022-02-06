"Telecope Plugin remaps"
 
  nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
  nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
  nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
  nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

" The primiagen original remaps
  "nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
  "nnoremap <leader>pw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
  "nnoremap <Leader>pf :lua require('telescope.builtin').find_files()<CR>
  "nnoremap <leader>pb :lua require('telescope.builtin').buffers()<CR>
  "nnoremap <leader>vh :lua require('telescope.builtin').help_tags()<CR>
  nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
  "git worktree extensions
  nnoremap <leader>gw :lua require('telescope').extensions.git_worktree.git_worktrees()<CR>
  noremap <leader>gm :lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>

"The primeiagen remaps modified to me 
  nnoremap <leader>fs :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
  nnoremap <leader>fw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
