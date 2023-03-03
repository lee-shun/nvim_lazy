return {
	"debugloop/telescope-undo.nvim",
	keys = { { "<leader>fu", "<cmd>Telescope undo<cr>", desc = "Find undo" } },
	config = function()
		require("telescope").setup({
			extensions = {
				undo = {
					side_by_side = true,
					mappings = {
						i = {
							-- IMPORTANT: Note that telescope-undo must be available when telescope is configured if
							-- you want to replicate these defaults and use the following actions. This means
							-- installing as a dependency of telescope in it's `requirements` and loading this
							-- extension from there instead of having the separate plugin definition as outlined
							-- above.
							["<C-a>"] = require("telescope-undo.actions").yank_additions,
							["<C-d>"] = require("telescope-undo.actions").yank_deletions,
							["<cr>"] = require("telescope-undo.actions").restore,
						},
					},
				},
			},
		})
		require("telescope").load_extension("undo")
	end,
}
