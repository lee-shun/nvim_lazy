return {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
        require("Comment").setup{}

        -- Comment.nvim bug: ft.calculate only guards `pcall` failure but not
        -- the case where vim.treesitter.get_parser returns nil (filetype has no
        -- installed tree-sitter parser). That leads to ft.contains(nil, ...) ->
        -- "attempt to index local 'tree' (a nil value)", swallowed as
        -- "[Comment.nvim] nil" by U.catch. Fall back to the filetype's
        -- commentstring when there is no usable parser.
        local ft = require("Comment.ft")
        local orig = ft.calculate
        ft.calculate = function(ctx)
            local ok, parser = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
            if not ok or not parser then
                return ft.get(vim.bo.filetype, ctx.ctype) or ft.get("c", ctx.ctype)
            end
            return orig(ctx)
        end
    end,
}
