return {
    -- Disabled: replaced by wsdjeg/rooter.nvim below (ahmedkhalf/project.nvim
    -- has been unmaintained since 2024-08). Spec kept for easy re-enable.
    {
        "ahmedkhalf/project.nvim",
        enabled = false,
        event = "VeryLazy",
        keys = {
            { "<leader>fP", "<cmd>Telescope projects<cr>", desc = "📁 Projects" },
        },
        opts = {
            manual_mode = false,
            detection_methods = { "pattern", "lsp" },
            patterns = {
                ".vim_root",
                "build",
                "clang-format",
                "compile_commands.json",
                ".git",
                ".svn",
                "Makefile",
                "package.json",
            },
            ignore_lsp = {},
            exclude_dirs = {},
            show_hidden = false,
            silent_chdir = true,
            datapath = vim.fn.stdpath("data"),
        },
        config = function(_, opts)
            require("project_nvim").setup(opts)
            require('telescope').load_extension('projects')
        end,
    },

    {
        "wsdjeg/rooter.nvim",
        -- Loaded eagerly on purpose: rooter registers BufEnter/VimEnter autocmds
        -- in setup(), so it must be on the runtimepath before the first file opens.
        -- Lazy triggers (event/keys) would load it too late for the initial buffer.
        opts = {
            -- dir patterns end with '/', file patterns do not (whole-replace of defaults)
            root_patterns = {
                ".git/",
                ".svn/",
                "build/",
                ".vim_root",
                "clang-format",
                "compile_commands.json",
                "Makefile",
                "package.json",
            },
            outermost = true,
            enable_cache = true,
            -- keep cwd unchanged for files outside any project ('' | 'home' | 'current')
            project_non_root = "",
            -- global cd, matching old project.nvim behavior (build scripts use vim.fn.getcwd())
            command = "cd",
        },
        config = function(_, opts)
            require("rooter").setup(opts)
            vim.keymap.set("n", "<leader>fP", "<cmd>Telescope project<cr>", { desc = "📁 Projects" })
        end,
    },
}
