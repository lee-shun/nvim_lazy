return {
	"nvim-telescope/telescope-frecency.nvim",
	dependencies = { "kkharji/sqlite.lua" },
	keys = {
		{ "<leader>fm", "<cmd>Telescope frecency<cr>", desc = "Find frecency" },
	},
	config = function()
		require("telescope").setup({
			extensions = {
				frecency = {
					show_scores = true,
					show_unindexed = true,
					ignore_patterns = { "*.git/*", "*/tmp/*" },
				},
			},
		})
		-- telescope extensions
		require("telescope").load_extension("frecency")
	end,
}
