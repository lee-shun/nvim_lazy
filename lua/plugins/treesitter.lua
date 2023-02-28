return {
	"nvim-treesitter/nvim-treesitter",
	event = "BufReadPost",
	build = ":TSUpdate",
	dependencies = {
		{ "p00f/nvim-ts-rainbow" },
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			highlight = {
				enable = true,
			},
			rainbow = {
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
			},
		})
	end,
}
