return {
    "rcarriga/nvim-notify",
    keys = {
        {
            "<leader>nu",
            function()
                require("notify").dismiss({ silent = true, pending = true })
            end,
            desc = "Delete all Notifications",
        },
    },
    opts = {
        timeout = 3000,
        max_height = function()
            return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
            return math.floor(vim.o.columns * 0.75)
        end,
    },
    config = function(_, opts)
        require("notify").setup(opts)
        require("telescope").load_extension("notify")

        local wk = require("which-key")
        wk.add(
            {
                { "<leader>fn", "<cmd>Telescope notify<cr>", desc = "Find notify", nowait = false, remap = false },
            }
        )
    end,
}
