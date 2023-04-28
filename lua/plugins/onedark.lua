return {
	"navarasu/onedark.nvim",
	enabled = false,
	opts = {
		style = "dark",
	},
	config = function(_, opts)
		require("onedark").setup(opts)
		vim.cmd("colorscheme onedark")
	end,
}
