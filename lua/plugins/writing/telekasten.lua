return {
    'renerocksai/telekasten.nvim',
    cmd = "Telekasten",
    enabled=false,
    dependencies = { 'nvim-telescope/telescope.nvim' },
    opts = {
        home = vim.fn.expand("~/knowledge_library"),
        image_link_style = "markdown",
        tag_notation = 'yaml-bare',
        take_over_my_home = false,
    },
}
