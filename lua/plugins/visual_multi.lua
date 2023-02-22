return {
	"mg979/vim-visual-multi",
	event = "BufReadPost",
	config = function()
		vim.g.VM_maps = { ["I BS"] = "" }
		vim.g.VM_set_statusline = 0
	end,
}
