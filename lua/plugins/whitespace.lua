return {
	"johnfrankmorgan/whitespace.nvim",
	event = { "BufReadPost" },
	config = function()
		require("whitespace-nvim").setup({
			highlight = "DiffDelete",
			ignored_filetypes = { "TelescopePrompt", "alpha", "git", "NvimTree", "toggleterm" },
		})
		vim.api.nvim_create_user_command("TrimWS", "lua require('whitespace-nvim').trim()", {})
	end,
}
