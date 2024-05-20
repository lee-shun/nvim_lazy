return {
    'Bekaboo/dropbar.nvim',
    event = "VeryLazy",
    enabled = false,
    dependencies = { "nvim-web-devicons" },
    config = function()
        require('dropbar').setup({

        })
    end
}
