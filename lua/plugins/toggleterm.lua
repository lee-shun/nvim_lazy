return {
	"akinsho/toggleterm.nvim",
	event = "BufReadPre",
	keys = {
		{
			"<F12>",
			"<cmd>ToggleTerm<cr>",
			"ToggleTerm",
		},
	},
	opts = { direction = "float" },
}
