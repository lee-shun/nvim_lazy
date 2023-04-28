return {
	"sainnhe/sonokai",
    enabled = false,
	config = function()
		vim.g.sonokai_better_performance = 1
		vim.g.sonokai_current_word = "grey background"
		vim.g.sonokai_diagnostic_virtual_text = "colored"
		vim.g.sonokai_spell_foreground = "colored"
		vim.cmd("colorscheme sonokai")
	end,
}
