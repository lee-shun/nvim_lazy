return {
    "debugloop/telescope-undo.nvim",
    keys = { { "<leader>fu", "<cmd>Telescope undo<cr>", desc = "🔄 Undo history" } },
    config = function()
        require("telescope").load_extension("undo")
    end,
}
