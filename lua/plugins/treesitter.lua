return {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    build = ":TSUpdate",
    dependencies = {
        {
            "nvim-treesitter/playground",
            cmd = "TSPlaygroundToggle",
        },
        {
            'andymass/vim-matchup',
            event = "VeryLazy",
            config = function()
                -- may set any options here
                vim.g.matchup_matchparen_offscreen = { method = "popup" }
            end
        },
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = {
                enable = true,
            },
            ensure_installed = {
                "markdown",
                "cpp",
                "c",
                "python",
                "latex",
                "lua",
                "bash",
                "vim",
                "regex",
                "markdown_inline",
                "toml",
                "yaml",
                "json",
                "vimdoc",
                "xml",
            },
            matchup = {
                enable = true, -- mandatory, false will disable the whole extension
            },
        })
    end,
}
