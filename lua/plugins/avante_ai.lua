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
                endpoint = "http://192.168.1.105:11434",
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
                endpoint = "http://192.168.1.105:8080/v1",
                model = "llamacpp_models",
                timeout = 1000000, -- Timeout in milliseconds
                disable_tools = true,
                api_key_name = "",
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
                    OPENCODE_API_KEY = os.getenv("OPENCODE_API_KEY"),
                }
            }
        }
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
        "stevearc/dressing.nvim",        -- for input provider dressing
        "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
        {
            -- Make sure to set this up properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
