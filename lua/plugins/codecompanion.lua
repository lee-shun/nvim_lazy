return {
    "olimorris/codecompanion.nvim",
    enabled = false,
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",              -- 可选：slash commands 补全
        "nvim-telescope/telescope.nvim", -- 可选：工具/命令选择
        "stevearc/dressing.nvim",        -- 可选：更好 UI
        {
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                file_types = { "markdown", "codecompanion" },
            },
            ft = { "markdown", "codecompanion" },
        },
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        adapters = {
            http = {
                ollama = function()
                    return require("codecompanion.adapters").extend("ollama", {
                        env = {
                            url = "http://192.168.1.105:11434",
                            api_key = "OLLAMA_API_KEY",
                        },
                        headers = {
                            ["Content-Type"] = "application/json",
                            ["Authorization"] = "Bearer ${api_key}",
                        },
                        schema = {
                            model = {
                                default = "qwen3-coder:latest"
                            }
                        },
                        parameters = {
                            sync = true,
                        },
                    })
                end,
            },
        },
        strategies = {
            chat = { adapter = "ollama" },
            inline = { adapter = "ollama" },
            agent = { adapter = "ollama" }, -- 如果想用工具调用
        },
        display = {
            chat = {
                show_settings=true,
            },
            action_palette = {
                provider = "telescope", -- 用 telescope 选 slash commands / tools
            },
        },
        -- 可选：开启调试日志，看连接细节
        -- opts = { log_level = "DEBUG" },
    },
}
