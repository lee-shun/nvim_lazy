return {
    "liuchengxu/vista.vim",
    enabled = true,
    cmd = "Vista",
    config = function()
        vim.g.vista_default_executive = "nvim_lsp"
    end,
}
