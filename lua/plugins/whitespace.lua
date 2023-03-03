return {
	"johnfrankmorgan/whitespace.nvim",
	event = "VeryLazy",
	config = function()
		require("whitespace-nvim").setup({
			highlight = "DiffDelete",
			ignored_filetypes = { "TelescopePrompt", "alpha", "git", "NvimTree", "toggleterm", "help", "noice", "lazy", "WhichKey"},
		})
		vim.api.nvim_create_user_command("TrimWS", "lua require('whitespace-nvim').trim()", {})
	end,
}
