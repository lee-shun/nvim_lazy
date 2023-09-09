return {
	"nvim-treesitter/nvim-treesitter",
	lazy = true,
	build = ":TSUpdate",
	dependencies = {
		{
			"nvim-treesitter/playground",
			cmd = "TSPlaygroundToggle",
		},
		{
			"p00f/nvim-ts-rainbow",
		},
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			highlight = {
				enable = true,
			},
			rainbow = {
				enable = true,
				-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
				extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
				max_file_lines = nil, -- Do not enable for files with more than n lines, int
				-- colors = {}, -- table of hex strings
				-- termcolors = {} -- table of colour name strings
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
