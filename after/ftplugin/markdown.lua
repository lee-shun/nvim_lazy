-- Minimal dispatcher: all Markdown logic lives in lua/lang/markdown.lua.
require("lang.markdown").setup(vim.api.nvim_get_current_buf())
