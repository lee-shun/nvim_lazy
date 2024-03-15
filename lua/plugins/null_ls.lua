return {
    "jose-elias-alvarez/null-ls.nvim",
    event = "VeryLazy",
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                -- null_ls.builtins.diagnostics.cpplint,
                null_ls.builtins.diagnostics.markdownlint,
                -- null_ls.builtins.diagnostics.pylint,
            },
        })
    end,
}
