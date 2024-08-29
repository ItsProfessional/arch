local util = require("amc.util")

local buffers = util.require_or_empty("amc.buffers")

-- run vimscript and write output to a new scratch buffer
vim.api.nvim_create_user_command("S", function(cmd)
  local out = vim.api.nvim_exec2(cmd.args, { output = true })
  if out then
    buffers.write_scratch(out.output)
  end
end, { nargs = "+", complete = "expression" })

