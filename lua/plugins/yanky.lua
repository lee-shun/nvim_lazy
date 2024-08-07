return {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    keys = {
        { "<leader>fy" },
        { "gp",        "<Plug>(YankyGPutAfter)" },
        { "gP",        "<Plug>(YankyGPutBefore)" },
        { "p",         "<Plug>(YankyPutAfter)" },
        { "P",         "<Plug>(YankyPutBefore)" },
    },
    dependencies = { "telescope.nvim" },
    config = function()
        local utils = require("yanky.utils")
        local mapping = require("yanky.telescope.mapping")
        local actions = require("telescope.actions")

        require("yanky").setup({
            picker = {
                telescope = {
                    mappings = {
                        default = mapping.put("p"),
                        i = {
                            ["<c-j>"] = actions.move_selection_next,
                            ["<c-k>"] = actions.move_selection_previous,
                            ["<c-x>"] = mapping.delete(),
                            ["<c-r>"] = mapping.set_register(utils.get_default_register()),
                        },
                        n = {
                            p = mapping.put("p"),
                            P = mapping.put("P"),
                            d = mapping.delete(),
                            r = mapping.set_register(utils.get_default_register()),
                        },
                    },
                },
            },
            highlight = {
                on_put = false,
                on_yank = false,
                timer = 500,
            },
            preserve_cursor_position = {
                enabled = true,
            },
        })

        -- telescope extensions
        require("telescope").load_extension("yank_history")
        -- keymaps
        local wk = require("which-key")
        wk.add(
            {
                { "<leader>fy", "<cmd>Telescope yank_history<cr>", desc = "Find yank history", nowait = false, remap = false },
            }
        )
    end,
}
