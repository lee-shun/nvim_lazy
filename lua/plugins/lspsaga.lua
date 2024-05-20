return {
    'nvimdev/lspsaga.nvim',
    config = function()
        require('lspsaga').setup({
            symbol_in_winbar = {
                enable = true,
                separator = '  ',
                hide_keyword = true,
                show_file = true,
                folder_level = 2,
            },
            lightbulb = {
                virtual_text = true,
                sign = false,
            }
        })
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
}
