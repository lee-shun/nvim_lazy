return {
    'renerocksai/telekasten.nvim',
    cmd = "Telekasten",
    dependencies = { 'nvim-telescope/telescope.nvim' },
    opts = {
        home = vim.fn.expand("~/knowledge_library"),
        image_link_style = "markdown",
        tag_notation = 'yaml-bare',
        take_over_my_home = false,
    },
    keys = {
        { "<leader>ln", "<cmd>LiteratureNewList<cr>", desc = "New Literature Notes" },
        { "<leader>lc", "<cmd>LiteratureCheck<cr>",   desc = "Check Literature Notes" },
        -- Launch panel if nothing is typed after <leader>z
        {"<leader>z", "<cmd>Telekasten panel<CR>"},
        -- Most used f{nctions
        {"<leader>zf", "<cmd>Telekasten find_notes<CR>", desc = "Telekasten find_notes"},
        {"<leader>zg", "<cmd>Telekasten search_notes<CR>", desc = "Telekasten search_notes"},
        {"<leader>zz", "<cmd>Telekasten follow_link<CR>", desc = "Telekasten follow_link"},
        {"<leader>zn", "<cmd>Telekasten new_note<CR>", desc = "Telekasten new_note"},
        {"<leader>zc", "<cmd>Telekasten show_calendar<CR>", desc = "Telekasten show_calendar"},
        {"<leader>zb", "<cmd>Telekasten show_backlinks<CR>", desc = "Telekasten show_backlinks"},
        {"<leader>zI", "<cmd>Telekasten insert_img_link<CR>", desc = "Telekasten insert_img_link"},
        {"<leader>zi", "<cmd>Telekasten insert_link<CR>", desc = "Telekasten insert_link"},
    },
    config = true
}
