vim.opt_local.textwidth = 80
vim.opt_local.spell = true

-- add keymaps
local buf = vim.api.nvim_get_current_buf()
require("which-key").register({
    ["rt"] = {
        function()
            vim.cmd([[exec "VimtexStop"]])
            vim.cmd([[exec "VimtexCompile"]])
        end,
        "Recompile",
    },
    ["rv"] = {
        function()
            vim.cmd([[exec "VimtexView"]])
        end,
        "View the pdf",
    },
}, {
    mode = "n",
    prefix = "<leader>",
    buffer = buf,
    silent = true,
    noremap = true,
    nowait = false,
})
