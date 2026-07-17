-- Minimal dispatcher: all LaTeX logic lives in lua/lang/tex.lua.
require("lang.tex").setup(vim.api.nvim_get_current_buf())
