" lua require("theprimeagen")

"harpoon add
nnoremap <silent><leader>ha :lua require("harpoon.mark").add_file()<CR>
" harpoon window
nnoremap <silent><C-e> :lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <silent><leader>hw :lua require("harpoon.cmd-ui").toggle_quick_menu()<CR>

nnoremap <silent><C-h> :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <silent><C-j> :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <silent><C-k> :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <silent><C-l> :lua require("harpoon.ui").nav_file(4)<CR>
