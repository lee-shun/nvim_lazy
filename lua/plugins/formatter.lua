return {
	"mhartington/formatter.nvim",
	cmd = "Format",
	config = function()
		-- Utilities for creating configurations
		local util = require("formatter.util")

		-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
		require("formatter").setup({
			-- Enable or disable logging
			logging = true,
			-- Set the log level
			log_level = vim.log.levels.WARN,
			-- All formatter configurations are opt-in
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				cpp = {
					require("formatter.filetypes.cpp").clangformat,
				},
				python = {
					require("formatter.filetypes.python").autopep8,
				},
				markdown = {
					require("formatter.filetypes.markdown").prettier,
				},
				["*"] = {
					require("formatter.filetypes.any").remove_trailing_whitespace,
				},
			},
		})
	end,
}
