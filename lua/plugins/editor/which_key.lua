return {
    "folke/which-key.nvim",
    dependencies = { "echasnovski/mini.icons", version = false },
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = 200,
        icons = {
            group = "▸ ",
            separator = "│ ",
            mappings = false,
            keys = {
                Up = "⬆️ ",
                Down = "⬇️ ",
                Left = "⬅️ ",
                Right = "➡️ ",
                C = "Ctrl+",
                M = "Alt+",
                D = "Cmd+",
                S = "Shift+",
                CR = "↵ ",
                Esc = "Esc ",
                ScrollWheelDown = "Scroll↓ ",
                ScrollWheelUp = "Scroll↑ ",
                NL = "NL ",
                BS = "⌫ ",
                Space = "Space ",
                Tab = "Tab ",
            },
        },
        win = {
            border = "rounded",
            title = true,
            title_pos = "center",
            padding = { 1, 1 },
        },
        layout = {
            height = { min = 4, max = 25 },
            width = { min = 20, max = 50 },
            spacing = 3,
        },
        plugins = {
            marks = true,
            registers = true,
            spelling = {
                enabled = true,
                suggestions = 20,
            },
        },
        replace = {
            desc = {
                { "<cmd>", "" },
                { "<Cmd>", "" },
                { "<CR>", "↵" },
                { "<cr>", "↵" },
                { "<leader>", " leader " },
            },
        },
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
    end,
}
