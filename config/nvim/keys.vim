nm	;	:
vm	;	:
nm	q;	q:
vm	q;	q:
nm	@;	@:
vm	@;	@:
nm	<C-w>; 	<C-w>:
vm	<C-w>; 	<C-w>:

nn	yw	yiw
nn	yfw	yw

nm	<silent>	<Esc>		<Esc>:nohlsearch<CR>
im	<silent>	<Esc>		<Esc>:nohlsearch<CR>

for s:leader in [ "\<Space>", "\<BS>", ]
let mapleader=s:leader

" begin left
nm	<silent>	<Leader>;	:NvimTreeCollapse<CR>
nm	<silent>	<Leader>a	:NvimTreeFindFile<CR>:NvimTreeFocus<CR>
nm	<silent>	<Leader>'	:call amc#win#closeInc()<CR>
nm	<silent>	<Leader>"	:call amc#win#closeAll()<CR>

nm	<silent>	<Leader>,	:NvimTreeRefresh<CR>
nm	<silent>	<Leader>o	:call amc#win#goHomeOrNext()<CR>
nm	<silent>	<Leader>O	:call amc#win#goHome()<CR>
nm	<silent>	<Leader>q	:call amc#win#goHome() <Bar> belowright copen 15 <CR>

nm	<silent>	<Leader>.	:if amc#qf#setGrepPattern() <Bar> set hlsearch <Bar> endif <Bar> cnext<CR>
nm	<silent>	<Leader>e	:call amc#win#openBufExplorer()<CR>
nm	<silent>	<Leader>j	:Gitsigns next_hunk<CR>

nm	<silent>	<Leader>p	:if amc#qf#setGrepPattern() <Bar> set hlsearch <Bar> endif <Bar> cprev<CR>
nm	<silent>	<Leader>u	:call amc#buf#safeHash()<CR>
nm	<silent>	<Leader>k	:Gitsigns prev_hunk<CR>

" y
nm	<silent>	<Leader>i	:call amc#win#goHome() <Bar> TagbarOpen fj<CR>
" x

nm	<silent>	<Space><BS>	:call amc#mru#back()<CR>
nm	<silent>	<BS><BS>	:call amc#mru#back()<CR>
" end left

" begin right
nm	<silent>	<Leader>f	:call amc#find()<CR>
nm	<silent>	<Leader>d	:call amc#clear()<CR>
nm	<silent>	<Leader>D	:call amc#clearDelete()<CR>
nm	<silent>	<Leader>b	:set mouse= <Bar> set mouse=a<CR>

nm			<Leader>g	:ag "<C-r>=expand('<cword>')<CR>"
nm			<Leader>G	:ag "<C-r>=expand('<cWORD>')<CR>"
vm			<Leader>g	"*y<Esc>:<C-u>ag "<C-r>=getreg("*")<CR>"
om	<silent>	gh		:<C-U>Gitsigns select_hunk<CR>
xm	<silent>	gh		:<C-U>Gitsigns select_hunk<CR>
nm	<silent>	<Leader>hs	:Gitsigns stage_hunk<CR>
vm	<silent>	<Leader>hs	:Gitsigns stage_hunk<CR>
nm	<silent>	<Leader>hx	:Gitsigns reset_hunk<CR>
vm	<silent>	<Leader>hx	:Gitsigns reset_hunk<CR>
nm	<silent>	<Leader>hS	:Gitsigns stage_buffer<CR>
nm	<silent>	<Leader>hu	:Gitsigns undo_stage_hunk<CR>
nm	<silent>	<Leader>hX	:Gitsigns reset_buffer<CR>
nm	<silent>	<Leader>hp	:Gitsigns preview_hunk<CR>
nm	<silent>	<Leader>hb	:lua require"gitsigns".blame_line{full=true}<CR>
nm	<silent>	<Leader>hl	:Gitsigns toggle_current_line_blame<CR>
nm	<silent>	<Leader>hd	:Gitsigns diffthis<CR>
nm	<silent>	<Leader>hD	:lua require"gitsigns".diffthis("~")<CR>
nm	<silent>	<Leader>ht	:Gitsigns toggle_deleted<CR>
nm	<silent>	<Leader>m	:make <CR>
nm	<silent>	<Leader>M	:make clean <CR>

nm	<silent>	<Leader>cu	<Plug>Commentary<Plug>Commentary
nm	<silent>	<Leader>cc	<Plug>CommentaryLine
om	<silent>	<Leader>c	<Plug>Commentary
nm	<silent>	<Leader>c	<Plug>Commentary
xm	<silent>	<Leader>c	<Plug>Commentary
nm	<silent>	<Leader>t	:call settagstack(win_getid(), {'items' : []})<CR><C-]>
nm	<silent>	<Leader>w	<Plug>ReplaceWithRegisterOperatoriw
xm	<silent>	<Leader>w	<Plug>ReplaceWithRegisterVisual
nm	<silent>	<Leader>W	<Plug>ReplaceWithRegisterLine

nm			<Leader>r	:%s/<C-r>=expand('<cword>')<CR>/
nm			<Leader>R	:%s/<C-r>=expand('<cword>')<CR>/<C-r>=expand('<cword>')<CR>
vm			<Leader>r	"*y<Esc>:%s/<C-r>=getreg("*")<CR>/
vm			<Leader>R	"*y<Esc>:%s/<C-r>=getreg("*")<CR>/<C-r>=getreg("*")<CR>
nm	<silent>	<Leader>n	:tn<CR>
nm	<silent>	<Leader>N	:tp<CR>
nm	<silent>	<Leader>v	:put<CR>'[v']=
nm	<silent>	<Leader>V	:put!<CR>'[v']=

" l
nm	<silent>	<Leader>s	:GotoHeaderSwitch<CR>
nm	<silent>	<Leader>z	gg=G``

nm			<Leader>/	/<C-r>=expand("<cword>")<CR><CR>
vm			<Leader>/	"*y<Esc>/<C-u><C-r>=getreg("*")<CR><CR>
nm	<silent>	<Leader>-	:GotoHeader<CR>
" \

nm	<silent>	<BS><Space>	:call amc#mru#forward()<CR>
nm	<silent>	<Space><Space>	:call amc#mru#forward()<CR>
" end right
endfor

cm		<C-j>	<Down>
cm		<C-k>	<Up>

" hacky vim clipboard=autoselect https://github.com/neovim/neovim/issues/2325
vm <LeftRelease> "*ygv

" no way to remap fugitive and tpope will not add
function s:fugitive_map()
	nm <buffer>t =
	nm <buffer>x X
endfunction
autocmd FileType fugitive call s:fugitive_map() 


" coc.nvim

" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
			\ pumvisible() ? "\<C-n>" :
			\ <SID>check_back_space() ? "\<TAB>" :
			\ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
			\: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" use <c-space>for trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

