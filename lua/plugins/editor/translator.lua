return {
    "IC-killer/transdog.nvim",
    -- 替换 voldikss/vim-translator（2023 停更，网页接口已死）
    -- sdcv 离线查词 + 本机 Ollama AI 翻译，全离线无 key
    -- sdcv: 免 root 装在 ~/.local/bin/sdcv（Ubuntu deb 解包），词典 ~/.stardict/dic/（ECDICT）
    -- AI: 走 ollama_shim（systemd user 服务 ollama-shim.service，11434 -> llama-server :8080）
    -- ollama 本体未安装（用户拍板不装），model 名字 shim 会忽略
    lazy = false,
    opts = {
        sdcv_cmd = "~/.local/bin/sdcv",
        ollama_model = "local-llama-server", -- shim 忽略此字段
        ollama_host = "http://127.0.0.1:11434", -- shim 转发到 llama-server
        stream = true,
        keymaps = {
            -- 保持旧 <leader>y：normal 查词（原 TranslateW），visual AI 翻译
            translate_word = "<leader>y",
            translate_ollama = "<leader>y",
        },
    },
    config = function(plugin)
        require("transdog").setup(plugin.opts)
        -- lualine 状态指示（翻译中/完成/错误）；lualine 可能还没加载，重试等待
        local status = {
            function()
                return require("transdog").lualine_status()
            end,
            cond = function()
                return require("transdog").lualine_status() ~= ""
            end,
        }
        local tries = 0
        local function install()
            if vim.g.lualine_section_x then
                table.insert(vim.g.lualine_section_x, 1, status)
            elseif tries < 50 then
                tries = tries + 1
                vim.defer_fn(install, 100)
            end
        end
        install()
    end,
}
