syntax on

" unnamedplus: yank etc. uses the + register, synced with XA_CLIPBOARD
" autoselect: visual selections go to * register, synced with XA_PRIMARY
set clipboard=unnamedplus,autoselect,exclude:cons\|linux

" these are nvim defaults
set autoread
set formatoptions+=j
set hlsearch
set showcmd
set listchars=trail:·,tab:>\ ,eol:¬

" alacritty, st, xterm and tmux all talk sgr
" terminus automatically sets it when under tmux
" vim hardcodes st to 'xterm' and xterm to 'sgr'
" sgr is desirable as one of its side effects is the ability to handle modified F1-F4
if ($TERM =~ 'alacritty' || $TERM =~ 'st-')
	set ttymouse=sgr
endif

" let the colorscheme set the (default light) background
set background=


let &rtp.="," . $XDG_CONFIG_HOME . "/nvim"
runtime init.vim


" vim cannot handle this
nunmap <Esc>

" sometimes terminal sends C-Space as Nul, so map it
ino	<expr>	<Nul>		amc#omni#begin()

" this is undesirably underlined
function ColorSchemeCustVim()
	highlight CursorLineNr cterm=NONE ctermfg=7
endfunction
autocmd ColorScheme * call ColorSchemeCustVim()

" nvim automatically does this
execute "colorscheme " . colors_name

