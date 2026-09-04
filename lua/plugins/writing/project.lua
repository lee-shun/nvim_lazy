return {
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
