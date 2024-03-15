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
    },
    config = function()
        local wk = require("which-key")
        -- keymaps
        local dap_map = {
            d = {
                name = "Nvim Dap",
                b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle breakpoint" },
                B = {
                    "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
                    "Set cond breakpoint",
                },
                c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
                s = { "<cmd>lua require'dap'.close()<cr>", "Close" },
                i = { "<cmd>lua require'dap'.step_into()<cr>", "Step into" },
                v = { "<cmd>lua require'dap'.step_over()<cr>", "Step over" },
                o = { "<cmd>lua require'dap'.step_out()<cr>", "Step out" },
                u = { "<cmd>lua require('dapui').toggle()<cr>", "DapUI toggle" },
            },
        }
        local dap_map_opt = {
            mode = "n",
            prefix = "<leader>",
            buffer = nil,
            silent = true,
            noremap = true,
            nowait = false,
        }
        wk.register(dap_map, dap_map_opt)

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
