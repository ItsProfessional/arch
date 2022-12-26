local log = require("amc.log")
local require = log.require

log.line("init.lua START", ...)

-- prevent netrw from loading
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- general options
vim.o.autowriteall = true
vim.o.clipboard = "unnamedplus"
vim.o.completeopt = "menu,menuone,noselect"
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.listchars = vim.o.listchars .. ",space:·"
vim.o.mouse = "a"
vim.o.number = true
vim.o.pumheight = 15
vim.o.pumwidth = 30
vim.o.shiftwidth = 4
vim.o.showcmd = false
vim.o.smartcase = true
vim.o.switchbuf = "useopen,uselast"
vim.o.tabstop = 4
vim.o.tags = "**/tags"
vim.o.title = true
vim.o.undofile = true
vim.o.wrapscan = false

log.line("init.lua options", ...)

-- legacy plugin options
vim.g.BufKillCreateMappings = 0
vim.g.zig_build_makeprg_params = "-Dxwayland --prefix ~/.local install"

log.line("init.lua legacy", ...)

require("amc.appearance")

require("amc.plugins.cmp")
require("amc.plugins.comment")
require("amc.plugins.gitsigns")
require("amc.plugins.lsp")
require("amc.plugins.lualine")
require("amc.plugins.nvim-tree")
require("amc.plugins.telescope")

require("amc.autocmd")

log.line("init.lua END", ...)
