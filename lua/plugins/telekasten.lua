return {
    'renerocksai/telekasten.nvim',
    cmd = "Telekasten",
    dependencies = { 'nvim-telescope/telescope.nvim' },
    opts = {
        home = vim.fn.expand("~/knowledge_library"),
        image_link_style = "markdown",
        tag_notation = 'yaml-bare',
    },
    config = true
}
