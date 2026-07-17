-- LaTeX filetype configuration.
-- Moved from after/ftplugin/tex.lua; text wrapping lives in util.wrap.

local M = {}

function M.setup(buf)
    vim.opt_local.textwidth = 80
    vim.opt_local.spell = true

    local wk = require("which-key")

    wk.add({
        {
            "<leader>xt",
            function()
                vim.cmd("VimtexStop")
                vim.cmd("VimtexCompile")
            end,
            buffer = buf,
            desc = "🔄 Recompile LaTeX",
        },
        {
            "<leader>xv",
            function()
                vim.cmd("VimtexView")
            end,
            buffer = buf,
            desc = "👁️ View PDF",
        },
        {
            "<leader>xb",
            function()
                require("util.wrap").wrap_selection("\\boldsymbol")
                vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                    "n",
                    false
                )
            end,
            buffer = buf,
            mode = { "n", "v" },
            desc = "𝐛 Bold (boldsymbol)",
        },
    })
end

return M
