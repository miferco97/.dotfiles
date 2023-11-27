-- space as the leader
vim.g.mapleader = ' '

-- esential command
vim.keymap.set('i','jj','<ESC>')

-- resize helpers
vim.keymap.set('n','<leader>+',':vertical resize +5 <CR>')
vim.keymap.set('n','<leader>-',':vertical resize -5 <CR>')


-- yank until end of the line
vim.keymap.set('n','Y','yg$')

-- center screen on next/previous selection
vim.keymap.set('n','n','nzz')
vim.keymap.set('n','N','Nzz')
vim.keymap.set('n','<C-o>','<C-o>zz')
vim.keymap.set('n','<C-i>','<C-i>zz')

--" next greatest remap ever : asbjornHaland

vim.keymap.set('n','<leader>y','"+y')
vim.keymap.set('v','<leader>y','"+y')
vim.keymap.set('n','<leader>Y','"+Y')


-- remaps for throw in delete
vim.keymap.set('x','<leader>p','"_dP')
vim.keymap.set('n','<leader>d','"_d')
vim.keymap.set('v','<leader>d','"_d')

 
-- no highlight
vim.keymap.set('n','<leader><C-n>',':nohl<CR>')

-- move through windows with ease
vim.keymap.set('n','<C-j>','<C-w>j')
vim.keymap.set('n','<C-k>','<C-w>k')
vim.keymap.set('n','<C-l>','<C-w>l')
vim.keymap.set('n','<C-h>','<C-w>h')

