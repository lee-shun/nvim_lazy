return {
	"rmagatti/session-lens",
    enabled = false,
	event = "VeryLazy",
	dependencies = {
		"rmagatti/auto-session",
		opts = {
			auto_session_root_dir = vim.fn.stdpath("config") .. "/tmp/session/",
		},
	},
	keys = {
		{ "<leader>fs", "<cmd>Telescope  session-lens search_session<cr>", desc = "Find sessions" },
	},
	config = function(_, opts)
		require("session-lens").setup(opts)
		require("telescope").load_extension("session-lens")
	end,
}
