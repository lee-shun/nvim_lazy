return {
    "pianocomposer321/yabs.nvim",
    event = "VeryLazy",
    keys = {
        { "<leader>rb", "<cmd>lua require('yabs'):run_task('build')<cr>", desc = "Build task" },
        { "<leader>rr", "<cmd>lua require('yabs'):run_task('run')<cr>",   desc = "Run task" },
    },
    config = function()
        local cpp_config = {
            default_task = "build_and_run",
            tasks = {
                build = {
                    command = function()
                        return "g++ -std=c++11 "
                            .. vim.fn.expand("%:t")
                            .. " -Wall -ggdb -o "
                            .. vim.fn.expand("%:t:r")
                            .. ".out"
                    end,
                    output = "quickfix",
                    opts = { open_on_run = "auto" },
                },
                run = {
                    command = function()
                        return "time ./" .. vim.fn.expand("%:t:r") .. ".out"
                    end,
                    output = "terminal",
                },
            },
        }

        require("yabs"):setup({
            languages = {
                cpp = cpp_config,
            },
        })

        local wk = require("which-key")
        wk.add({
            { "<leader>r", group = "Task runner", nowait = false, remap = false },
        })
    end,
}

-- yabs.nvim
