return {
	"kkoomen/vim-doge",
    ft = {"cpp", "c", "python"},
    build = ":call doge#install()",
	config = function()
    vim.g.doge_mapping_comment_jump_forward = '<tab>'
    vim.g.doge_mapping_comment_jump_backward = '<s-tab>'
    vim.g.doge_comment_jump_modes = {'n'}
	end,
}
