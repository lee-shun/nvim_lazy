return {
	"junegunn/vim-easy-align",
	event = "BufReadPost",
	keys = {
		{ "ga", "<Plug>(EasyAlign)", desc = "EasyAlign", mode = { "n", "x" } },
	},
}
