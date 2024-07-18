vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.spell = true

local buf = vim.api.nvim_get_current_buf()

require("which-key").add({
    "<leader>rm",
    function()
        vim.cmd([[exec "MarkdownPreview" ]])
    end
    ,
    buffer = buf,
    desc = "Preview",
    nowait = false,
    remap = false
})
