return {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    build = ":TSUpdate",
    dependencies = {
        {
            "nvim-treesitter/playground",
            cmd = "TSPlaygroundToggle",
        },
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = {
                enable = true,
            },
            ensure_installed = {
                "markdown",
                "markdown_inline",
                "cpp",
                "c",
                "python",
                "lua",
                "bash",
                "vim",
                "regex",
                "toml",
                "yaml",
                "json",
                "vimdoc",
                "xml",
            },
            markdown = {
                enable = true,
            },
        })
    end,
}
