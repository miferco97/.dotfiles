set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'nvim-lua/popup.nvim'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'nvim-telescope/telescope.nvim'
Plugin 'nvim-telescope/telescope-fzy-native.nvim'
Plugin 'cdelledonne/vim-cmake'
Plugin 'tpope/vim-commentary'
Plugin 'github/copilot.vim'
Plugin 'rhysd/vim-clang-format'
Plugin 'Yggdroot/indentLine'

Plugin 'sonph/onehalf', { 'rtp': 'vim' }
Plugin 'Mofiqul/vscode.nvim'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

"plugins"

"call plug#begin()
"Plug 'nvim-lua/popup.nvim'
"Plug 'nvim-lua/plenary.nvim'
"Plug 'nvim-telescope/telescope.nvim'
"Plug 'nvim-telescope/telescope-fzy-native.nvim'
"Plug 'sonph/onehalf', { 'rtp': 'vim' }
"Plug 'cdelledonne/vim-cmake'

"Plug 'gruvbox-community/gruvbox'
"Plug 'junegunn/fzf', {'do':{ -> fzf#install()}}"

"call plug#end()

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
nnoremap n nzzzv
nnoremap J mzJ`z

vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv


"nmap fs <Plug>(YCMFindSymbolInWorkspace)
nnoremap gd :YcmCompleter GoTo<CR>e
nnoremap gr :YcmCompleter GoReferences<CR>e
nnoremap gh :YcmCompleter GetDoc<CR>e


