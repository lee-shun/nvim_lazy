-- 局域网 AI 服务器地址：可用环境变量 NVIM_AI_HOST 覆盖（换网络不用改配置）
local ai_host = os.getenv("NVIM_AI_HOST") or "192.168.1.105"

return {
    "yetone/avante.nvim",
    enabled = true,
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
        -- add any opts here
        -- this file can contain specific instructions for your project
        -- mode = "agentic",
        mode = "legacy", -- Switch from "agentic" to "legacy"
        instructions_file = "avante.md",
        -- provider = "opencode",
        provider = "llamacpp",
        providers = {
            ollama = {
                endpoint = "http://" .. ai_host .. ":11434",
                -- model = "devstral-small-2",
                -- model = "qwen3-coder:latest",
                -- model = "deepseek-coder-v2",
                model = "glm-4.7-flash",
                timeout = 1000000, -- Timeout in milliseconds
                disable_tools = false,
                extra_request_body = {
                    temperature = 0,
                    max_tokens = 4096,
                },
            },
            llamacpp = {
                __inherited_from = "openai",
                endpoint = "http://" .. ai_host .. ":8080/v1",
                model = "llamacpp_models",
                timeout = 1000000, -- Timeout in milliseconds
                disable_tools = false,
                api_key_name = "TERM",
                extra_request_body = {
                    temperature = 0,
                    max_tokens = 4096,
                },
            },
        },
        acp_providers = {
            ["opencode"] = {
                command = "opencode",
                args = {"acp"},
                env = {
                    OPENCODE_API_KEY = os.getenv("TERM"),
                }
            }
        }
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        { "saghen/blink.compat", opts = {} }, -- autocompletion for avante commands and mentions (via blink.cmp)
        "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
        "MeanderingProgrammer/render-markdown.nvim",
        -- bare dependency; full spec owned by lua/plugins/writing/markdown_render.lua
    },
    keys = {
        { "<leader>aa", "<cmd>Avante<cr>", desc = "🤖 Avante chat" },
        { "<leader>ac", "<cmd>AvanteClose<cr>", desc = "❌ Close Avante" },
        { "<leader>ap", "<cmd>AvanteProvider<cr>", desc = "⚙️ Avante provider" },
        { "<leader>as", "<cmd>AvanteSuggestion<cr>", desc = "💡 Avante suggestion" },
    },
    config = function(_, opts)
        require("avante").setup(opts)
    end,
}
