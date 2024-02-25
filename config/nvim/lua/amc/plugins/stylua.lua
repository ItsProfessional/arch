local stylua = require("stylua-nvim")

local M = {}

if not stylua then
  return M
end

local config = {
  error_display_strategy = "loclist",
}

-- init
stylua.setup(config)

return M
