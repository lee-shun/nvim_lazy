return {
	"lukas-reineke/indent-blankline.nvim",
	event = "VeryLazy",
	dependencies = {
		"TheGLander/indent-rainbowline.nvim",
	},
	opts = function(_, opts)
		opts = {
			char = "┆",
			show_current_context = true,
			show_current_context_start = true,
			context_patterns = {
				"class",
				"function",
				"method",
				"^if",
				"^else",
				"^else if",
				"^while",
				"^for",
				"^object",
				"^table",
				"block",
			},
			show_end_of_line = false,
			filetype_exclude = { "help", "Nvimtree", "coc-explorer", "dashboard", "alpha", "noice" },
			buftype_exclude = { "terminal", "prompt" },
		}
		return require("indent-rainbowline").make_opts(opts)
	end,
	config = function(_, opts)
		require("indent_blankline").setup({})
		require("indent_blankline").setup(opts)
	end,
}
