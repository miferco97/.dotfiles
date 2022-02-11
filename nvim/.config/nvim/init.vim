set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
" set rtp+=~/.config/nvim/bundle/Vundle.vim
" call vundle#begin()
" " let Vundle manage Vundle, required
" Plugin 'VundleVim/Vundle.vim'
" Plugin 'ycm-core/YouCompleteMe'
" Plugin 'nvim-lua/popup.nvim'
" Plugin 'nvim-lua/plenary.nvim'
" Plugin 'nvim-telescope/telescope.nvim'
" Plugin 'nvim-telescope/telescope-fzy-native.nvim'
" Plugin 'Shatur/neovim-cmake'
" Plugin 'mfussenegger/nvim-dap'
" Plugin 'tpope/vim-commentary'
" Plugin 'github/copilot.vim'
" Plugin 'rhysd/vim-clang-format'
" Plugin 'Yggdroot/indentLine'
" Plugin 'bfrg/vim-cpp-modern'
" Plugin 'Mofiqul/vscode.nvim'
" " All of your Plugins must be added before the following line
" call vundle#end()            " required
" filetype plugin indent on    " required
"plugins"

call plug#begin()
Plug 'VundleVim/Vundle.vim'
" Plug 'ycm-core/YouCompleteMe'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'Shatur/neovim-cmake'
Plug 'tpope/vim-commentary'
Plug 'github/copilot.vim'
Plug 'rhysd/vim-clang-format'
Plug 'Yggdroot/indentLine'
Plug 'bfrg/vim-cpp-modern'
Plug 'Mofiqul/vscode.nvim'
Plug 'puremourning/vimspector'
Plug 'mfussenegger/nvim-dap'
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

" nnoremap gd :YcmCompleter GoTo<CR>e
" nnoremap gr :YcmCompleter GoToReferences<CR>e
" nnoremap gh :YcmCompleter GetType<CR>e
" nnoremap <leader>gd :YcmCompleter GetDoc<CR>e

command Trex :Vex | :vertical resize 35

let g:cpp_function_highlight = 1
" Enable highlighting of C++11 attributes
let g:cpp_attributes_highlight = 1
" Highlight struct/class member variables (affects both C and C++ files)
let g:cpp_member_highlight = 1
" Highlight C++11 keywords

syntax on
set mouse=a
