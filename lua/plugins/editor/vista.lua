return {
    "liuchengxu/vista.vim",
    enabled = true,
    keys = { { "<leader>fs", "<cmd>Vista<cr>", desc = "📊 Symbols outline" } },
    cmd = "Vista",
    config = function()
        vim.g.vista_default_executive = "nvim_lsp"
    end,
}
