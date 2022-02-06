"plugins"

call plug#begin()
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

Plug 'sonph/onehalf', { 'rtp': 'vim' }
"Plug 'gruvbox-community/gruvbox'

"Plug 'junegunn/fzf', {'do':{ -> fzf#install()}}"

call plug#end()

set t_Co=256
set cursorline
colorscheme onehalfdark
let g:airline_theme='onehalfdark'
" lightline
"let g:lightline = { 'colorscheme': 'onehalfdark' }
"key maps"

let mapleader = " "

nnoremap <Leader>w :w<CR>
nnoremap <Leader>+ :vertical resize +5<CR>
nnoremap <Leader>- :vertical resize -5<CR>

nnoremap <CR> o<ESC>

inoremap jj <ESC>
nnoremap Y yg$
nnoremap n nzzzv
nnoremap J mzJ`z

vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv
