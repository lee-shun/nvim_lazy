return {
    "liuchengxu/vista.vim",
    enabled = false,
    cmd = "Vista",
    config = function()
        vim.g.vista_default_executive = "nvim_lsp"
    end,
}
