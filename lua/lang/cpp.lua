-- C/C++ filetype configuration.
-- Moved from after/ftplugin/c,cpp.lua.

local M = {}

function M.setup(buf)
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2

    local wk = require("which-key")

    wk.add({
        {
            "<leader>rs",
            function()
                vim.cmd([[
            exec "!g++ -std=c++11 -ggdb % -Wall -o %<.out"
            exec "!time ./%<.out"
        ]])
            end,
            buffer = buf,
            desc = "▶️ Run file",
        },
    })
end

return M
