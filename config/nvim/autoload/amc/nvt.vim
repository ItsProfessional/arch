" nvim only
"
" FEATURE: update_focused_file.ignore_list for all

function amc#nvt#setup()
	set termguicolors

	lua require 'nvt'
endfunction

function amc#nvt#startup()
	if amc#buf#flavour(bufnr()) == g:amc#buf#NO_NAME_NEW
		NvimTreeOpen

		" events aren't fired within VimEnter so manually clasify
		call amc#win#markSpecial()
	endif
endfunction

" only to workaround bugs
" https://github.com/kyazdani42/nvim-tree.lua/issues/969
" https://github.com/kyazdani42/nvim-tree.lua/issues/970
function amc#nvt#sync()
	if amc#buf#flavour(bufnr()) == g:amc#buf#ORDINARY_HAS_FILE
		NvimTreeRefresh
	endif
endfunction

function amc#nvt#smartFocus()
	if amc#buf#flavour(bufnr()) == g:amc#buf#ORDINARY_HAS_FILE
		NvimTreeFindFile
	else
		NvimTreeFocus
	endif
endfunction

