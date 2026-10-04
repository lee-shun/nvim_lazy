return {
    "IC-killer/transdog.nvim",
    -- 替换 voldikss/vim-translator（2023 停更，网页接口已死）
    -- sdcv 离线查词 + 本机 Ollama AI 翻译，全离线无 key
    -- sdcv: 免 root 装在 ~/.local/bin/sdcv（Ubuntu deb 解包），词典 ~/.stardict/dic/（ECDICT）
    -- ollama: 用户态装在 ~/.local/ollama/，`ollama serve` 监听 127.0.0.1:11434
    lazy = false,
    opts = {
        sdcv_cmd = "~/.local/bin/sdcv",
        ollama_cmd = "~/.local/ollama/ollama",
        ollama_model = "translategemma:4b",
        ollama_host = "http://127.0.0.1:11434", -- 走本机 HTTP API
        stream = true,
        keymaps = {
            -- 保持旧 <leader>y：normal 查词（原 TranslateW），visual AI 翻译
            translate_word = "<leader>y",
            translate_ollama = "<leader>y",
        },
    },
    config = function(plugin)
        require("transdog").setup(plugin.opts)
        -- lualine 状态指示（翻译中/完成/错误）
        local status = {
            function()
                return require("transdog").lualine_status()
            end,
            cond = function()
                return require("transdog").lualine_status() ~= ""
            end,
        }
        table.insert(vim.g.lualine_section_x, 1, status)
    end,
}
