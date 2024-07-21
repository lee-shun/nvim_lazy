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
        })
    end,
}
