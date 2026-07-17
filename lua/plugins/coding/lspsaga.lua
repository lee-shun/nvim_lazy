return {
    'nvimdev/lspsaga.nvim',
    event = 'VeryLazy',
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

        vim.api.nvim_create_autocmd('BufRead', {
            group = vim.api.nvim_create_augroup('LspSaga', { clear = true }),
            callback = function()
                local curbuf = vim.api.nvim_get_current_buf()
                require('lspsaga.symbol.winbar').init_winbar(curbuf)
            end
        })
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
}
