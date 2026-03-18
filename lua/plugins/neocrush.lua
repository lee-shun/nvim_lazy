return {
    'taigrr/neocrush.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'taigrr/glaze.nvim' },
    event = 'VeryLazy',
    enabled=false,
    opts = {
        -- All options are optional with sensible defaults
        highlight_group = 'IncSearch', -- Flash highlight group
        highlight_duration = 900,  -- Flash duration (ms)
        auto_focus = true,         -- Auto-focus edited files
        terminal_width = 80,       -- Terminal width in columns
        terminal_cmd = 'crush',    -- Command to run in terminal

        -- CVM configuration (optional)
        cvm = {
            upstream = 'charmbracelet/crush', -- GitHub repo for releases
            local_repo = '~/code/crush', -- Default path for :CrushCvmLocal
        },

        -- Optional keybindings (none set by default)
        keys = {
            toggle = '<leader>cc',
            focus = '<leader>cf',
            logs = '<leader>cl',
            cancel = '<leader>cx',
            restart = '<leader>cr',
            paste = '<leader>cp', -- Works in normal (clipboard) and visual (selection) mode
            cvm_releases = '<leader>cvr',
            cvm_local = '<leader>cvl',
        },
    },
}
