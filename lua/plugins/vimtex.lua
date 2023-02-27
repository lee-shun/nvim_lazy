return {
	"lervag/vimtex",
	ft = "tex",
	config = function()
		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_quickfix_mode = 0
		vim.g.vimtex_mappings_enabled = 0
		vim.g.vimtex_imaps_enabled = 0
		vim.g.vimtex_text_obj_enabled = 1
		vim.g.vimtex_fold_enabled = 1
		vim.g.tex_conceal = "abdmg"
		vim.g.vimtex_format_enabled = 1
	end,
}
