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
        -- 注：keymaps 选项是死选项（plugin/transdog.lua 在 setup 前就读它），键位在下方 config 显式注册
    },
    config = function(plugin)
        require("transdog").setup(plugin.opts)
        -- 注：plugin/transdog.lua 会在 config 前用空 opts 注册默认 <leader>tt，先删掉再绑 <leader>y
        pcall(vim.keymap.del, "n", "<leader>tt")
        pcall(vim.keymap.del, "v", "<leader>tt")
        vim.keymap.set("n", "<leader>y", function() require("transdog").translate_word() end, { desc = "📖 查词（sdcv）" })
        vim.keymap.set("v", "<leader>y", function() require("transdog").translate_with_ollama() end, { desc = "🐕 AI 翻译选中" })
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
