vim.opt_local.textwidth = 80
vim.opt_local.spell = true

-- add keymaps
local buf = vim.api.nvim_get_current_buf()

require("which-key").add({
    {
        "<leader>rt",
        function()
            vim.cmd([[exec "vimtexstop"]])
            vim.cmd([[exec "vimtexcompile"]])
        end,
        buffer = buf,
        desc = "Recompile",
        nowait = false,
        remap = false
    },
    {
        "<leader>rv",
        function()
            vim.cmd([[exec "VimtexView"]])
        end,
        buffer = buf,
        desc = "View the pdf",
        nowait = false,
        remap = false
    },
})
