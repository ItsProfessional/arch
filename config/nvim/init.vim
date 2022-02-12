filetype off
call vundle#begin("~/.local/share/nvim/vundle")
Plugin 'airblade/vim-gitgutter'
Plugin 'chriskempson/base16-vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-repeat'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'Yohannfra/Vim-Goto-Header'
if has('nvim')
	Plugin 'kyazdani42/nvim-tree.lua'
else
	Plugin 'preservim/nerdtree'
	Plugin 'Xuyuanp/nerdtree-git-plugin'
	Plugin 'wincent/terminus'
endif
call vundle#end()
filetype plugin indent on


set clipboard=unnamedplus
set ignorecase
set smartcase
set nowrapscan
set autowriteall
set number
set cursorline
set mouse=a
set undofile
set title
set switchbuf=useopen,uselast


nmap	;	:
vmap	;	:
nmap	q;	q:
vmap	q;	q:
nmap	@;	@:
vmap	@;	@:
nmap	<C-w>; 	<C-w>:
vmap	<C-w>; 	<C-w>:

nmap	<silent>	<Esc>		<Esc>:nohlsearch<CR>
imap	<silent>	<Esc>		<Esc>:nohlsearch<CR>

" begin left
let mapleader="\<Space>"

if has('nvim')
	nmap	<silent>	<Leader>a	:call amc#nvt#smartFocus()<CR>
else
	nmap	<silent>	<Leader>;	:call amc#nt#smartFind()<CR>
	nmap	<silent>	<Leader>a	:call amc#nt#smartFocus()<CR>
endif
nmap	<silent>	<Leader>'	:call amc#win#closeInc()<CR>
nmap	<silent>	<Leader>"	:call amc#win#closeAll()<CR>

nmap	<silent>	<Leader>,	:call amc#win#openFocusGitPreview()<CR>
nmap	<silent>	<Leader><	:cclose<CR>
nmap	<silent>	<Leader>o	:call amc#win#goHomeOrNext()<CR>
nmap	<silent>	<Leader>O	:call amc#win#goHome()<CR>
nmap	<silent>	<Leader>q	:call amc#win#goHome() <Bar> belowright copen 15 <CR>

nmap	<silent>	<Leader>.	:call amc#qf#setGrepPattern()<Bar>set hlsearch<Bar>cnext<CR>
nmap	<silent>	<Leader>e	:call amc#win#goHome() <Bar> BufExplorer<CR>
nmap	<silent>	<Leader>j	<Plug>(GitGutterNextHunk)
let	g:NERDTreeGitStatusMapNextHunk = "<Space>j"

nmap	<silent>	<Leader>p	:call amc#qf#setGrepPattern()<Bar>set hlsearch<Bar>cprev<CR>
nmap	<silent>	<Leader>u	:call amc#buf#safeHash()<CR>
nmap	<silent>	<Leader>k	<Plug>(GitGutterPrevHunk)
let	g:NERDTreeGitStatusMapPrevHunk = "<Space>k"

" y
nmap	<silent>	<Leader>i	:call amc#win#goHome() <Bar> TagbarOpen fj<CR>
" x

nmap	<silent>	<BS><BS>	:call amc#mru#back()<CR>
" end left

" begin right
let mapleader="\<BS>"

" f
nmap	<silent>	<Leader>d	:call amc#mru#winRemove()<CR>
" b

nmap			<Leader>g	:ag "<C-r>=expand('<cword>')<CR>"
nmap			<Leader>G	:ag "<C-r>=expand('<cWORD>')<CR>"
vmap			<Leader>g	:<C-u>ag "<C-r>=amc#vselFirstLine()<CR>"
nmap	<silent>	<Leader>hu	<Plug>(GitGutterUndoHunk)
nmap	<silent>	<Leader>hs	<Plug>(GitGutterStageHunk)
xmap	<silent>	<Leader>hs	<Plug>(GitGutterStageHunk)
nmap	<silent>	<Leader>m	:make <CR>
nmap	<silent>	<Leader>M	:make clean <CR>

nmap	<silent>	<Leader>cu	<Plug>Commentary<Plug>Commentary
nmap	<silent>	<Leader>cc	<Plug>CommentaryLine
omap	<silent>	<Leader>c	<Plug>Commentary
nmap	<silent>	<Leader>c	<Plug>Commentary
xmap	<silent>	<Leader>c	<Plug>Commentary
nmap	<silent>	<Leader>t	<C-]>
nmap	<silent>	<Leader>T	:call settagstack(win_getid(), {'items' : []})<CR>
" vim-repeat doesn't seem to be able to handle a <BS> mapping
nmap	<silent>	<F12>w		viwp:let @+=@0<CR>:let @"=@0<CR>:call repeat#set("\<F12>w")<CR>
nmap	<silent>	<Leader>w	<F12>w

nmap			<Leader>r	:%s/<C-r>=expand('<cword>')<CR>/
nmap			<Leader>R	:%s/<C-r>=expand('<cword>')<CR>/<C-r>=expand('<cword>')<CR>
vmap			<Leader>r	:<C-u>%s/<C-r>=amc#vselFirstLine()<CR>/
vmap			<Leader>R	:<C-u>%s/<C-r>=amc#vselFirstLine()<CR>/<C-r>=amc#vselFirstLine()<CR>
nmap	<silent>	<Leader>n	:tn<CR>
nmap	<silent>	<Leader>N	:tp<CR>
nmap	<silent>	<F12>v		:call amc#linewiseIndent("p", "\<F12>v")<CR>
nmap	<silent>	<Leader>v	<F12>v
nmap	<silent>	<F12>V		:call amc#linewiseIndent("P", "\<F12>V")<CR>
nmap	<silent>	<Leader>V	<F12>V

" l
nmap	<silent>	<Leader>s	:GotoHeaderSwitch<CR>
nmap	<silent>	<Leader>z	gg=G``

" /
nmap	<silent>	<Leader>-	:GotoHeader<CR>
" \

nmap	<silent>	<Space><Space>	:call amc#mru#forward()<CR>

unlet mapleader
" end right

cmap		<C-j>	<Down>
cmap		<C-k>	<Up>

" hacky vim clipboard=autoselect https://github.com/neovim/neovim/issues/2325
vmap <LeftRelease> "*ygv


" appearance
if match(system('underlyingterm'), 'st-256color\|alacritty') >= 0
	let base16colorspace=256
	autocmd ColorScheme * call amc#colours()
	colorscheme base16-bright
else
	set background=dark
endif

" grep
set grepprg=ag\ --vimgrep\ --debug
let &grepformat="ERR: %m,DEBUG: Query is %o,%-GDEBUG:%.%#,%f:%l:%c:%m,%f"
command -nargs=+ AG silent grep! <args> <Bar> set hlsearch
cabbrev ag AG

" errorformat
let s:ef_cmocha = "%.%#[   LINE   ] --- %f:%l:%m,"
let s:ef_make = "make: *** [%f:%l:%m,"
let s:ef_cargo = "\\ %#--> %f:%l:%c,"
let &errorformat = s:ef_cmocha . s:ef_make . s:ef_cargo . &errorformat

" put the results of a silent command in a new scratch
command -nargs=+ S enew | setlocal buftype=nofile | setlocal bufhidden=hide | setlocal noswapfile | redir @z | silent <args> | redir end | put z

" default only in vim: return to last edit point
autocmd BufReadPost *
			\ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
			\ |   exe "normal! g`\""
			\ | endif

" find
cabbrev f find
" unused command kept here for reference
" command -nargs=1 -complete=file_in_path F call amc#win#goHome() | find <args>
" cabbrev f F

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

" bufexplorer
let g:bufExplorerDefaultHelp=0
let g:bufExplorerDisableDefaultKeyMapping=1
let g:bufExplorerShowNoName=1

" editorconfig
let EditorConfig_max_line_indicator='line'

" Goto-Header
let g:goto_header_associate_cpp_h = 1
let g:goto_header_includes_dirs = [".", "/usr/include"]

if has('nvim')
	" nvimtree
	call amc#nvt#setup()
else
	" nerdtree
	set wildignore+=*.o,*.class
	let NERDTreeRespectWildIgnore = 1
	let NERDTreeMinimalUI = 1
	let g:NERDTreeDirArrowExpandable = '+'
	let g:NERDTreeDirArrowCollapsible = '-'
	let g:NERDTreeMapQuit = '<Esc>'

	" nerdtree-git-plugin
	let g:NERDTreeGitStatusDirDirtyOnly = 0
	let g:NERDTreeGitStatusIndicatorMapCustom = {
				\ "Modified"  : "~",
				\ "Staged"    : "+",
				\ "Untracked" : "u",
				\ "Renamed"   : "r",
				\ "Unmerged"  : "*",
				\ "Deleted"   : "d",
				\ "Dirty"     : "x",
				\ "Clean"     : "c",
				\ 'Ignored'   : 'i',
				\ "Unknown"   : "?"
				\ }
endif

" tagbar
let g:tagbar_compact=1
let tagbar_map_showproto=''
let g:tagbar_silent = 1

" vim-commentary
autocmd FileType c setlocal commentstring=//\ %s
autocmd FileType cpp setlocal commentstring=//\ %s
" stop the plugin from creating the default mappings
nmap	gc	<NOP>

" vim-gitgutter
set updatetime=100
let g:gitgutter_close_preview_on_escape = 1
let g:gitgutter_preview_win_floating = 0
let g:gitgutter_preview_win_location = 'aboveleft'


" local overrides
call amc#sourceIfExists("local.vim")
call amc#sourceIfExists("amc/local.vim")

" event order matters
autocmd BufEnter * call amc#win#markSpecial()
autocmd BufEnter * call amc#win#ejectFromSpecial()
autocmd BufEnter * call amc#buf#wipeAltNoNameNew()
autocmd BufEnter * call amc#mru#update()
autocmd BufEnter * call amc#updateTitleString()
if has('nvim')
	autocmd BufEnter * call amc#nvt#sync()
else
	autocmd BufEnter * call amc#nt#sync()
end
autocmd BufLeave * call amc#buf#autoWrite()
autocmd BufWritePost * call amc#updateTitleString()
autocmd DirChanged global call amc#updatePath()
autocmd FileType * call amc#win#markSpecial()
autocmd FileType qf call amc#qf#setGrepPattern()
autocmd FocusGained * call amc#updateTitleString()
autocmd FocusLost * call amc#buf#autoWrite()
autocmd QuickfixCmdPost * ++nested call amc#qf#cmdPost()
autocmd VimEnter * call amc#startupCwd()
autocmd VimEnter * call amc#updateTitleString()
if has('nvim')
	autocmd VimEnter * call amc#nvt#startup()
else
	autocmd VimEnter * call amc#nt#startup()
endif
autocmd WinNew * call amc#mru#winNew()

" log
" let g:amcLog = 1
" let g:amcLogMru = 1
" call amc#log#startEventLogging()

