-- Minimal dispatcher: all Typst logic lives in lua/lang/typst.lua.
require("lang.typst").setup(vim.api.nvim_get_current_buf())
