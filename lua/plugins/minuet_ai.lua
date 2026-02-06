return {
    'milanglacier/minuet-ai.nvim',
    event = "VeryLazy",
    dependencies = {
        { 'nvim-lua/plenary.nvim' },
        { 'hrsh7th/nvim-cmp' },
    },
    config = function()
        require('minuet').setup {
            virtualtext = {
                auto_trigger_ft = { "*" },
                keymap = {
                    -- accept whole completion
                    accept = '<A-A>',
                    -- accept one line
                    accept_line = '<A-a>',
                    -- accept n lines (prompts for number)
                    -- e.g. "A-z 2 CR" will accept 2 lines
                    accept_n_lines = '<A-z>',
                    -- Cycle to prev completion item, or manually invoke completion
                    prev = '<A-[>',
                    -- Cycle to next completion item, or manually invoke completion
                    next = '<A-]>',
                    dismiss = '<A-e>',
                },
            },
            provider = 'openai_fim_compatible',
            n_completions = 1, -- recommend for local model for resource saving
            -- I recommend beginning with a small context window size and incrementally
            -- expanding it, depending on your local computing power. A context window
            -- of 512, serves as an good starting point to estimate your computing
            -- power. Once you have a reliable estimate of your local computing power,
            -- you should adjust the context window to a larger value.
            context_window = 2000,
            provider_options = {
                openai_fim_compatible = {
                    -- For Windows users, TERM may not be present in environment variables.
                    -- Consider using APPDATA instead.
                    api_key = 'TERM',
                    name = 'ollama',
                    end_point = 'http://192.168.1.105:11434/v1/completions',
                    model = "codestral",
                    -- model = "deepseek-coder-v2",
                    -- model = "glm-4.7-flash",
                    optional = {
                        max_tokens = 20480,
                        temperature=0.75,
                        stop=nil
                    },
                },
            },
        }
    end,
}
