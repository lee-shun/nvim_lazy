return {
    "nvim-treesitter/nvim-treesitter",
    -- 新版 main API：不支持懒加载，setup 只配 install_dir；
    -- parser 用 install{} 安装，高亮按语言 autocmd 开启
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local langs = {
            "markdown", "markdown_inline", "cpp", "c", "python",
            "lua", "bash", "vim", "regex", "toml", "yaml", "json", "vimdoc", "xml",
        }
        require("nvim-treesitter").setup({})
        require("nvim-treesitter").install(langs)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = langs,
            callback = function()
                vim.treesitter.start()
            end,
        })
    end,
}
