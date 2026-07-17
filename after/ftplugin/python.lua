-- Minimal dispatcher: all Python logic lives in lua/lang/python.lua.
require("lang.python").setup(vim.api.nvim_get_current_buf())
