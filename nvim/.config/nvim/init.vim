set nocompatible              " be iMproved, required
filetype off                  " required

call plug#begin()
Plug 'VundleVim/Vundle.vim'
" Plug 'ycm-core/YouCompleteMe'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'Shatur/neovim-cmake'
" Plug 'tpope/vim-commentary'
Plug 'miferco97/kommentary'
Plug 'github/copilot.vim'
Plug 'rhysd/vim-clang-format'
Plug 'Yggdroot/indentLine'
Plug 'bfrg/vim-cpp-modern'
Plug 'Mofiqul/vscode.nvim'
Plug 'puremourning/vimspector'
Plug 'mfussenegger/nvim-dap'
Plug 'ThePrimeagen/harpoon'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
" Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'

call plug#end()

let g:vimspector_enable_mappings = 'HUMAN'

set t_Co=256
set cursorline

let g:vscode_style = "dark"
" For light theme
"let g:vscode_style = "light"
" Enable transparent background.
let g:vscode_transparency = 1
" Enable italic comment
let g:vscode_italic_comment = 1
colorscheme vscode

let mapleader = " "

nnoremap <Leader>w :w<CR>
nnoremap <Leader>+ :vertical resize +5<CR>
nnoremap <Leader>- :vertical resize -5<CR>


nnoremap <CR> o<ESC>

inoremap jj <ESC>

nnoremap Y yg$
" nnoremap n nzzzv
nnoremap J mzJ`z

" Center screen on next/previous selection.
nnoremap n nzz
nnoremap N Nzz
" Last and next jump should center too.
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz

vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

" greatest remap ever
xnoremap <leader>p "_dP

" next greatest remap ever : asbjornHaland
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nmap <leader>Y "+Y

nnoremap <leader>d "_d
vnoremap <leader>d "_d

let g:cpp_function_highlight = 1
" Enable highlighting of C++11 attributes
let g:cpp_attributes_highlight = 1
" Highlight struct/class member variables (affects both C and C++ files)
let g:cpp_member_highlight = 1
" Highlight C++11 keywords
 
nnoremap <Leader><C-n> :nohl<CR>

lua << EOF
vim.g.kommentary_create_default_mappings = false
vim.api.nvim_set_keymap("n", "gcc", "<Plug>kommentary_line_default", {})
vim.api.nvim_set_keymap("v", "gc", "<Plug>kommentary_visual_singles<C-c>", {})
vim.api.nvim_set_keymap("v", "ga", "<Plug>kommentary_visual_default<C-c>", {})
EOF

" require'nvim-tree'.setup()

command Trex :NvimTreeToggle
" command Trex :NvimTreeToggle | :vertical resize 35

syntax on
set mouse=a

" move through windows with <C- dir>
" nnoremap <C-h> :wincmd h<CR>
" nnoremap <C-j> :wincmd j<CR>
" nnoremap <C-k> :wincmd k<CR>
" nnoremap <C-l> :wincmd l<CR>

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 100})
augroup END

