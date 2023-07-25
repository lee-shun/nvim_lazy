return {
	"tibabit/vim-templates",
	cmd = { "TemplateInit", "TemplateExpand" },
	keys = {
		{ "<leader>ft", "<cmd>Telescope find_template<cr>", desc = "Find file templates" },
	},
	config = function()
		vim.g.tmpl_auto_initialize = 0
		vim.g.tmpl_search_paths = { vim.fn.stdpath("config") .. "/template" }
		vim.g.tmpl_author_name = "shun li"
		vim.g.tmpl_author_email = "shun.li.at.casia@outlook.com"

		require("telescope").load_extension("find_template")
	end,
}
