-- Python filetype configuration.
-- Moved from after/ftplugin/python.lua.

local M = {}

function M.setup(_)
    vim.opt_local.textwidth = 80
end

return M
