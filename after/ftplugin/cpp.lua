vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2

local wk = require("which-key")
local buf = vim.api.nvim_get_current_buf()
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
        desc = "RunSingleFile",
        nowait = false,
        remap = false
    },
})
