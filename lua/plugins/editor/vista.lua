return {
    "liuchengxu/vista.vim",
    enabled = true,
    keys = { { "<leader>vt", "<cmd>Vista<cr>", desc = "📊 Vista outline" } },
    cmd = "Vista",
    config = function()
        vim.g.vista_default_executive = "nvim_lsp"
    end,
}
