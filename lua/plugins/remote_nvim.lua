return {
	"amitds1997/remote-nvim.nvim",
	version = "*",
	cmd = { "RemoteInfo", "RemoteStart" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("remote-nvim").setup({})
	end,
}
