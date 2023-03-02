vim.opt_local.tabstop=2
vim.opt_local.softtabstop=2
vim.opt_local.shiftwidth=2


local wk = require("which-key")
wk.register({
	["rs"] = {
		function()
			vim.cmd([[
                    exec "!g++ % -ggdb -o %<.out"
                    exec "!time ./%<.out"
            ]])
		end,
		"RunSingleFile",
	},
}, {
	mode = "n",
	prefix = "<leader>",
	buffer = 0,
	silent = true,
	noremap = true,
	nowait = false,
})
