return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- 锁定旧版 API（main 分支是完全重写，highlight/ensure_installed 会被静默忽略）
    lazy = true,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
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
