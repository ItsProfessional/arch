local util = require("amc.util")
local plugins = require("amc.plugins")

local buffers = util.require_or_empty("amc.buffers")
local dev = util.require_or_empty("amc.dev")
local windows = util.require_or_empty("amc.windows")

local K = {}

-- stylua: ignore start
for _, mode in ipairs({ "n", "i", "c", "v", "x", "s", "o" }) do
  K[mode .. "m" .. "__"] = function(lhs, rhs) if rhs then vim.keymap.set(mode, lhs, rhs, { remap = false }) end end
  K[mode .. "m" .. "s_"] = function(lhs, rhs) if rhs then vim.keymap.set(mode, lhs, rhs, { remap = false, silent = true }) end end
  K[mode .. "m" .. "_l"] = function(lhs, rhs) if rhs then for _, leader in ipairs({ "<Space>", "<BS>" }) do K[mode .. "m" .. "__"](leader .. lhs, rhs) end end end
  K[mode .. "m" .. "sl"] = function(lhs, rhs) if rhs then for _, leader in ipairs({ "<Space>", "<BS>" }) do K[mode .. "m" .. "s_"](leader .. lhs, rhs) end end end
end
-- stylua: ignore end

-- hacky vim clipboard=autoselect https://github.com/neovim/neovim/issues/2325
K.vm__("<LeftRelease>", '"*ygv')

K.nm__(";", ":")
K.vm__(";", ":")
K.nm__("q;", "q:")
K.vm__("q;", "q:")

K.nms_("yn", ':let @+ = expand("%:t")<CR>')
K.nms_("yr", ':let @+ = expand("%:.")<CR>')
K.nms_("ya", ':let @+ = expand("%:p")<CR>')

K.cm__("<C-j>", "<Down>")
K.cm__("<C-k>", "<Up>")

-- normal mode escape clears highlight
local ESC = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
K.nm__("<Esc>", function()
  vim.cmd.nohlsearch()
  vim.api.nvim_feedkeys(ESC, "n", false)
end)

--
-- begin left
--

-- &
-- $
-- @
-- fn

-- [
K.nmsl(";", vim.cmd.copen)
K.nmsl(":", vim.cmd.cclose)
K.nmsl("a", plugins.nvt.open_find)
K.nmsl("A", plugins.nvt.open_find_update_root)
K.nmsl("'", windows.close_inc)
K.nmsl('"', windows.close_others)

-- {
K.nmsl(",", plugins.fugitive.open)
K.nmsl("o", windows.go_home_or_next)
K.nmsl("O", vim.cmd.only)
K.nmsl("q", windows.close)

K.nm_l("}", ": <C-r>=expand('%:p')<CR><Home>")
K.nm_l("3", ": <C-r>=expand('%:.')<CR><Home>")
K.nmsl(".", plugins.lsp.goto_next)
K.nmsl("e", windows.cnext)
-- j gitsigns.next_hunk

K.nm_l("(", ": <C-r>=expand('<cword>')<CR><Home>")
K.vm_l("(", '"*y: <C-r>=getreg("*")<CR><Home>')
K.nmsl("p", plugins.lsp.goto_prev)
K.nmsl("u", windows.cprev)
-- k gitsigns.prev_hunk

-- =
K.nmsl("y", plugins.telescope.git_status)
K.nmsl("i", plugins.telescope.buffers)
K.nm_l("I", plugins.telescope.builtin)
K.nmsl("x", ":silent BA<CR>")

K.nms_("<Space><BS>", ":silent BB<CR>")
K.nms_("<BS><BS>", ":silent BB<CR>")

--
-- end left
--

--
-- begin right
--

K.nm__("*", "<Plug>(asterisk-z*)")
K.nm_l("*", "*")
K.nmsl("f", plugins.telescope.find_files)
K.nmsl("F", plugins.telescope.find_files_hidden)
K.nmsl("da", vim.lsp.buf.code_action)
K.nmsl("dq", vim.diagnostic.setqflist)
K.nmsl("df", vim.diagnostic.open_float)
K.nmsl("dh", vim.lsp.buf.hover)
K.nmsl("dl", plugins.telescope.diagnostics)
K.nmsl("dr", dev.lsp_rename)
K.nmsl("b", ":%y<CR>")
K.nmsl("B", ":%d_<CR>")

-- )
K.nmsl("g", plugins.telescope.live_grep)
K.nmsl("G", plugins.telescope.live_grep_hidden)
K.nmsl("hb", ":G blame<CR>")
-- h* gitsigns
K.nmsl("mc", dev.clean)
K.nmsl("mi", dev.install)
K.nmsl("mm", dev.build)
K.nmsl("mt", dev.test)
K.nmsl("ms", dev.source)

K.nmsl("+", plugins.rainbow.toggle)
K.nmsl("cu", "<Plug>Commentary<Plug>Commentary")
K.nmsl("cc", "<Plug>CommentaryLine")
K.omsl("c", "<Plug>Commentary")
K.nmsl("c", "<Plug>Commentary")
K.xmsl("c", "<Plug>Commentary")
K.nmsl("t", plugins.lsp.goto_definition_or_tag)
K.nmsl("T", vim.lsp.buf.declaration)
K.nmsl("w", "<Plug>ReplaceWithRegisterOperatoriw")
K.xmsl("w", "<Plug>ReplaceWithRegisterVisual")
K.nmsl("W", "<Plug>ReplaceWithRegisterLine")

-- ]
K.nm_l("r", ":%s/<C-r>=expand('<cword>')<CR>/")
K.nm_l("R", ":%s/<C-r>=expand('<cword>')<CR>/<C-r>=expand('<cword>')<CR>")
K.vm_l("r", '"*y:%s/<C-r>=getreg("*")<CR>/')
K.vm_l("R", '"*y:%s/<C-r>=getreg("*")<CR>/<C-r>=getreg("*")<CR>')
K.nmsl("n", plugins.telescope.lsp_references)
K.nmsl("N", vim.diagnostic.setqflist)
K.nmsl("v", ":put<CR>'[v']=")
K.nmsl("V", ":put!<CR>'[v']=")

-- !
K.nmsl("l", buffers.toggle_whitespace)
K.nmsl("L", buffers.trim_whitespace)
K.nm_l("s", ":lua require('amc.plugins.telescope').live_grep( { default_text = '<C-r>=expand('<cword>')<CR>', initial_mode = \"normal\" })<CR>")
K.nm_l("S", ":lua require('amc.plugins.telescope').live_grep( { default_text = '<C-r>=expand('<cWORD>')<CR>', initial_mode = \"normal\" })<CR>")
K.vmsl("s", "\"*y<Esc>:<C-u>lua require('amc.plugins.telescope').live_grep( { default_text = '<C-r>=getreg(\"*\")<CR>' })<CR>")
K.nmsl("z", dev.format)

K.nm__("#", "<Plug>(asterisk-z#)")
K.nm_l("#", "#")
-- /
K.nm_l("-", ":GotoHeaderSwitch<CR>")
K.nm_l("_", ":GotoHeader<CR>")
K.nmsl("\\", ":silent BW!<CR>")
K.nmsl("|", buffers.wipe_all)

K.nms_("<BS><Space>", ":silent BF<CR>")
K.nms_("<Space><Space>", ":silent BF<CR>")

--
-- end right
--

--
-- wincmd overrides
--

K.nms_("<C-w>t", ":wincmd j<CR>")
K.nms_("<C-w><C-t>", ":wincmd j<CR>")

K.nms_("<C-w>c", ":wincmd k<CR>")
-- K.nm__("<C-w><C-c>", ":wincmd k<CR>") doc states this does not work as <C-c> cancels the command

K.nms_("<C-w>n", ":wincmd l<CR>")
K.nms_("<C-w><C-n>", ":wincmd l<CR>")

K.nms_("<C-w>m", ":wincmd p<CR>")
K.nms_("<C-w><C-m>", ":wincmd p<CR>")

-- stop vim-commentary from creating the default mappings
K.nm__("gc", "<NOP>")

-- vim-vsnip - <Plug> links to the wrong place
vim.cmd([[
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)' : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)' : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
]])

