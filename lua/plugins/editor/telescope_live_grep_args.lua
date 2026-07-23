return {
    "nvim-telescope/telescope-live-grep-args.nvim",
    keys = { { "<leader>fW", "<cmd>Telescope live_grep_args<cr>", desc = "🔍 Live grep args" } },
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("telescope").load_extension("live_grep_args")
    end,
}
