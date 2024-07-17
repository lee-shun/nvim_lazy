return {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
        {
            "theHamsta/nvim-dap-virtual-text",
            config = true,
        },
        {
            "rcarriga/nvim-dap-ui",
            config = function()
                local dap, dapui = require("dap"), require("dapui")
                dapui.setup({})

                dap.listeners.after.event_initialized["dapui_config"] = function()
                    dapui.open({})
                end
                dap.listeners.before.event_terminated["dapui_config"] = function()
                    dapui.close({})
                end
                dap.listeners.before.event_exited["dapui_config"] = function()
                    dapui.close({})
                end
            end,
        },
        { "nvim-neotest/nvim-nio" }
    },
    config = function()
        local wk = require("which-key")
        wk.add(
            {
                { "<leader>d",  group = "Nvim Dap",                                                                 nowait = false,               remap = false },
                { "<leader>dB", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", desc = "Set cond breakpoint", nowait = false, remap = false },
                { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>",                                    desc = "Toggle breakpoint",   nowait = false, remap = false },
                { "<leader>dc", "<cmd>lua require'dap'.continue()<cr>",                                             desc = "Continue",            nowait = false, remap = false },
                { "<leader>di", "<cmd>lua require'dap'.step_into()<cr>",                                            desc = "Step into",           nowait = false, remap = false },
                { "<leader>do", "<cmd>lua require'dap'.step_out()<cr>",                                             desc = "Step out",            nowait = false, remap = false },
                { "<leader>ds", "<cmd>lua require'dap'.close()<cr>",                                                desc = "Close",               nowait = false, remap = false },
                { "<leader>du", "<cmd>lua require('dapui').toggle()<cr>",                                           desc = "DapUI toggle",        nowait = false, remap = false },
                { "<leader>dv", "<cmd>lua require'dap'.step_over()<cr>",                                            desc = "Step over",           nowait = false, remap = false },
            })

        -- show the winbar
        local dapWinbar = vim.api.nvim_create_augroup("DapWinbar", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "dap*" },
            command = "setlocal winbar=%f",
            group = dapWinbar,
        })

        local dap = require("dap")
        --
        -- cpp
        --

        -- adapter
        dap.adapters.cppdbg = {
            id = "cppdbg",
            type = "executable",
            command = "/home/ls/.language_tools/cpptools-linux/extension/debugAdapters/bin/OpenDebugAD7",
        }

        -- gdb
        dap.configurations.cpp = {
            {
                name = "Launch file",
                type = "cppdbg",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopAtEntry = true,
            },
        }

        --
        -- c
        --
        dap.configurations.c = dap.configurations.cpp

        --
        -- python
        --
    end,
}
