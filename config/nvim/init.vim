let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
let g:loaded_perl_provider = 0

filetype off
call vundle#begin("~/.local/share/nvim/vundle")

Plugin 'chriskempson/base16-vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'folke/which-key.nvim'
Plugin 'hashivim/vim-terraform'
Plugin 'hrsh7th/cmp-buffer'
Plugin 'hrsh7th/cmp-cmdline'
Plugin 'hrsh7th/cmp-nvim-lsp'
Plugin 'hrsh7th/cmp-path'
Plugin 'hrsh7th/cmp-vsnip'
Plugin 'hrsh7th/nvim-cmp'
Plugin 'hrsh7th/vim-vsnip'
Plugin 'lewis6991/gitsigns.nvim'
Plugin 'neovim/nvim-lspconfig'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'nvim-telescope/telescope.nvim'
Plugin 'nvim-tree/nvim-tree.lua'
Plugin 'nvim-tree/nvim-web-devicons'
Plugin 'qpkorr/vim-bufkill'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-repeat'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-scripts/ReplaceWithRegister'
Plugin 'xorid/asciitree.nvim'
Plugin 'Yohannfra/Vim-Goto-Header'
Plugin 'ziglang/zig.vim'

" plugin and coc-settings.json retained for coc replications
" Plugin 'neoclide/coc.nvim'

call vundle#end()
filetype plugin indent on

set autowriteall
set clipboard=unnamedplus
set completeopt=menu,menuone,noselect
set cursorline
set ignorecase
set lcs+=space:·
set mouse=a
set nowrapscan
set number
set pumheight=15
set pumwidth=30
set shiftwidth=4
set smartcase
set switchbuf=useopen,uselast
set tabstop=4
set termguicolors
set title
set undofile

runtime keys.vim

" appearance
if match(system('underlyingterm'), 'st-256color\|alacritty') >= 0
	let base16colorspace=256
	autocmd ColorScheme * call amc#colours()
	colorscheme base16-bright
else
	set background=dark
endif

" errorformat
let s:ef_cmocha = "%.%#[   LINE   ] --- %f:%l:%m,"
let s:ef_make = "make: *** [%f:%l:%m,"
let s:ef_cargo = "\\ %#--> %f:%l:%c,"
let &errorformat = s:ef_cmocha . s:ef_make . s:ef_cargo . &errorformat

" put the results of a silent command in " and +
command -nargs=+ C redir @" | silent exec <q-args> | redir end | let @+ = @"

" reset mouse
command MR set mouse= | set mouse=a

" clear macros; can't persist emtpy macro so 0 will do
command MC for i in range(char2nr('a'), char2nr('z')) | call setreg(nr2char(i), "0") | endfor | unlet i

" default only in vim: return to last edit point
autocmd BufReadPost *
			\ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
			\ |   exe "normal! g`\""
			\ | endif

" tags search down only
set tags=**/tags

" airline
set noshowmode
let g:airline#extensions#branch#enabled = 0
let g:airline#extensions#searchcount#enabled = 0
let g:airline_section_x=''
let g:airline_section_y = airline#section#create_right(['filetype'])
call airline#parts#define('colnr', { 'raw': '%v ', 'accent': 'none'})
call airline#parts#define('linenr', { 'raw': '%l', 'accent': 'bold'})
call airline#parts#define('maxlinenr', { 'raw': '/%L', 'accent': 'none'})
let g:airline_section_z = airline#section#create(['colnr', 'linenr', 'maxlinenr'])
let g:airline#extensions#whitespace#checks=['trailing', 'conflicts']
call airline#add_statusline_func('amc#airlineStatusLine')
call airline#add_inactive_statusline_func('amc#airlineStatusLine')

" buf-kill
let g:BufKillCreateMappings = 0

" editorconfig
let EditorConfig_max_line_indicator='line'

" Goto-Header
let g:goto_header_associate_cpp_h = 1
let g:goto_header_includes_dirs = [".", "/usr/include"]

" vim-commentary
autocmd FileType c setlocal commentstring=//\ %s
autocmd FileType cpp setlocal commentstring=//\ %s
" stop the plugin from creating the default mappings
nmap	gc	<NOP>

" zig
let g:zig_build_makeprg_params="-Dxwayland --prefix ~/.local install"

" "init.lua"
lua require 'amc/init'


" event order matters
autocmd BufEnter * call amc#buf#wipeAltNoNameNew()
autocmd BufEnter * call amc#updateTitleString()
autocmd BufLeave * ++nested silent! update
autocmd BufWritePost * call amc#updateTitleString()
autocmd DirChanged global call amc#updatePath()
autocmd FocusGained * call amc#updateTitleString()
autocmd FocusLost * ++nested silent! update
autocmd VimEnter * call amc#startupCwd()
autocmd VimEnter * call amc#updateTitleString()
autocmd WinClosed * call amc#win#wipeOnClosed()

" log
" call amc#log#startEventLogging()

