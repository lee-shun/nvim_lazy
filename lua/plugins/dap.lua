return {
	"mfussenegger/nvim-dap",
	event = "BufReadPost",
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
