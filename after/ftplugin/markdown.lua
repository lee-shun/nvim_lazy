vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.spell = true

local buf = vim.api.nvim_get_current_buf()
require("which-key").register({
	["rm"] = {
		function()
			vim.cmd([[exec "MarkdownPreview" ]])
		end,
		"Preview",
	},
}, {
	mode = "n",
	prefix = "<leader>",
	buffer = buf,
	silent = true,
	noremap = true,
	nowait = false,
})
