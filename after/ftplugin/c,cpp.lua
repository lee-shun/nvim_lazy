-- Minimal dispatcher: all C/C++ logic lives in lua/lang/cpp.lua.
require("lang.cpp").setup(vim.api.nvim_get_current_buf())
