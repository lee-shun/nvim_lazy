return {
	"nvim-treesitter/nvim-treesitter",
	lazy = true,
	build = ":TSUpdate",
	dependencies = {
		{ "p00f/nvim-ts-rainbow" },
		{ "andymass/vim-matchup" },
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			highlight = {
				enable = true,
			},
			rainbow = {
				enable = true,
			},
			matchup = { enable = true },
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
			},
		})
	end,
}
