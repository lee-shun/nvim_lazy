return {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    keys = { { "<leader>fT", "<cmd>TodoTelescope<cr>", desc = "✅ Todo comments" } },
    config = function(_, opts)
        require("todo-comments").setup(opts)
    end,
    opts = {
        highlight = {
            before = "",
            keyword = "bg",
            after = "fg",
            pattern = [[.*<(KEYWORDS)(\([^\)]*\))?:]],
            comments_only = true,
            max_line_len = 400,
            exclude = {},
        },
        search = {
            command = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
            },
            pattern = [[\b(KEYWORDS)(\([^\)]*\))?:]],
        },
        keywords = {
            FIX = {
                icon = "",
                color = "error",
                alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
            },
            TODO = { icon = "", color = "info" },
            HACK = { icon = "", color = "warning", alt = { "DEBUG" } },
            WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = "", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = "", color = "hint", alt = { "INFO" } },
            STEP = { icon = "", color = "#BB8FCE", alt = { "Step" } },
        },
    },
}
