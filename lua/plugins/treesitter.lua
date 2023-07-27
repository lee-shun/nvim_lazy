return {
	"nvim-treesitter/nvim-treesitter",
	lazy = true,
	build = ":TSUpdate",
	dependencies = {
		{
			"HiPhish/rainbow-delimiters.nvim",
			config = function()
				-- This module contains a number of default definitions
				local rainbow_delimiters = require("rainbow-delimiters")

				require("rainbow-delimiters.setup")({
					strategy = {
						[""] = rainbow_delimiters.strategy["global"],
						commonlisp = rainbow_delimiters.strategy["local"],
					},
					query = {
						[""] = "rainbow-delimiters",
						latex = "rainbow-blocks",
					},
					highlight = {
						"RainbowDelimiterRed",
						"RainbowDelimiterYellow",
						"RainbowDelimiterBlue",
						"RainbowDelimiterOrange",
						"RainbowDelimiterGreen",
						"RainbowDelimiterViolet",
						"RainbowDelimiterCyan",
					},
					-- blacklist = { "c", "cpp" },
				})
			end,
		},
		{
			"nvim-treesitter/playground",
			cmd = "TSPlaygroundToggle",
		},
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			highlight = {
				enable = true,
			},
			ensure_installed = {
				"markdown",
				"cpp",
				"c",
				"python",
				"latex",
				"lua",
				"bash",
				"vim",
				"regex",
				"markdown_inline",
				"toml",
				"yaml",
				"json",
			},
		})
	end,
}
