return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "opencode_output", "Avante", "codecompanion" },
	opts = {
		anti_conceal = { enabled = false },
		file_types = { "markdown", "opencode_output", "Avante", "codecompanion" },
	},
	dependencies = { "nvim-treesitter/nvim-treesitter"}, -- if you use the mini.nvim suite
}
