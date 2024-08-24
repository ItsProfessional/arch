local util = require("amc.util")

local M = {
  cmp = util.require_or_empty("amc.plugins.cmp"),
  fugitive = util.require_or_empty("amc.plugins.fugitive"),
  gitsigns = util.require_or_empty("amc.plugins.gitsigns"),
  lsp = util.require_or_empty("amc.plugins.lsp"),
  lualine = util.require_or_empty("amc.plugins.lualine"),
  nvt = util.require_or_empty("amc.plugins.nvt"),
  rainbow = util.require_or_empty("amc.plugins.rainbow"),
  stylua = util.require_or_empty("amc.plugins.stylua"),
  telescope = util.require_or_empty("amc.plugins.telescope"),
  treesitter = util.require_or_empty("amc.plugins.treesitter"),
}

return M
