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
        wk.add({
            { "<leader>dB", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", desc = "🔴 Set cond breakpoint" },
            { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>",                                    desc = "🔴 Toggle breakpoint" },
            { "<leader>dc", "<cmd>lua require'dap'.continue()<cr>",                                             desc = "▶️ Continue" },
            { "<leader>di", "<cmd>lua require'dap'.step_into()<cr>",                                            desc = "⏬ Step into" },
            { "<leader>do", "<cmd>lua require'dap'.step_out()<cr>",                                             desc = "⏫ Step out" },
            { "<leader>ds", "<cmd>lua require'dap'.close()<cr>",                                                desc = "❌ Close" },
            { "<leader>du", "<cmd>lua require('dapui').toggle()<cr>",                                           desc = "🖥️ Toggle DapUI" },
            { "<leader>dv", "<cmd>lua require'dap'.step_over()<cr>",                                            desc = "➡️ Step over" },
        })

        -- DAP winbar autocmd lives in lua/config/autocmds.lua (global scope)

        local dap = require("dap")
        --
        -- cpp
        --

        -- adapter
        -- cppdbg 路径：可用环境变量 NVIM_CPPDBG_PATH 覆盖
        -- 启动时不检查文件是否存在（这个不常用，别每次启动都弹警告）；
        -- 真缺了的话，nvim-dap 在实际启动调试会话时才会报错：
        -- "Executable `...` not found, fix the adapter definition for `cppdbg`"
        local cpptools_path = os.getenv("NVIM_CPPDBG_PATH")
            or vim.fn.expand("~/.language_tools/cpptools-linux/extension/debugAdapters/bin/OpenDebugAD7")
        dap.adapters.cppdbg = {
            id = "cppdbg",
            type = "executable",
            command = cpptools_path,
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
