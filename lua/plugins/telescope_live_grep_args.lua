return {
	"nvim-telescope/telescope-live-grep-args.nvim",
	keys = { { "<leader>fW", "<cmd>Telescope live_grep_args<cr>", desc = "Find word args" } },
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local lga_actions = require("telescope-live-grep-args.actions")

		telescope.setup({
			extensions = {
				live_grep_args = {
					auto_quoting = true, -- enable/disable auto-quoting
					-- define mappings, e.g.
					mappings = { -- extend mappings
						i = {
							["<C-i>"] = lga_actions.quote_prompt(),
						},
					},
					-- ... also accepts theme settings, for example:
					-- theme = "dropdown", -- use dropdown theme
					-- theme = { }, -- use own theme spec
					-- layout_config = { mirror=true }, -- mirror preview pane
				},
			},
		})
		telescope.load_extension("live_grep_args")
	end,
}
