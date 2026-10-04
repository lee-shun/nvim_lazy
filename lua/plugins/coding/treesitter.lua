return {
    "nvim-treesitter/nvim-treesitter",
    -- 新版 main API：不支持懒加载，setup 只配 install_dir；
    -- parser 用 install{} 安装，高亮按语言 autocmd 开启
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local langs = {
            "markdown", "markdown_inline", "cpp", "c", "python",
            "lua", "bash", "zsh", "vim", "regex", "toml", "yaml", "json", "vimdoc", "xml",
        }
        require("nvim-treesitter").setup({})
        require("nvim-treesitter").install(langs)
        vim.api.nvim_create_autocmd("FileType", {
            -- 高亮触发按 filetype：含 sh（bash parser 覆盖 sh/zsh 脚本）
            pattern = vim.list_extend(langs, { "sh" }),
            callback = function()
                -- sh/zsh 等 filetype 与 parser 名不一致时显式映射，避免 warning
                local ft2lang = { sh = "bash" }
                vim.treesitter.start(0, ft2lang[vim.bo.filetype])
            end,
        })
    end,
}
