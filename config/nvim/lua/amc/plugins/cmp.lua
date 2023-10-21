local util = require("amc.util")
local cmp = util.require_or_nil("cmp")

local M = {}

if not cmp then
  return M
end

local config = {
  completion = {
    autocomplete = false,
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "nvim_lua" }, -- '_G.', 'vim.`
  }),
}

--init
cmp.setup(config)

return M
