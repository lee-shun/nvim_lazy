return {
	"gbprod/yanky.nvim",
	cmd = { "Telescope" },
	keys = { "<leader>f" },
    dependencies = {"telescope.nvim"},
	config = function()
		local utils = require("yanky.utils")
		local mapping = require("yanky.telescope.mapping")

		require("yanky").setup({
			picker = {
				telescope = {
					mappings = {
						default = mapping.put("p"),
						i = {
							["<c-x>"] = mapping.delete(),
							["<c-r>"] = mapping.set_register(utils.get_default_register()),
						},
						n = {
							p = mapping.put("p"),
							P = mapping.put("P"),
							d = mapping.delete(),
							r = mapping.set_register(utils.get_default_register()),
						},
					},
				},
			},
			highlight = {
				on_put = false,
				on_yank = false,
				timer = 500,
			},
			preserve_cursor_position = {
				enabled = true,
			},
		})

		-- telescope extensions
		require("telescope").load_extension("yank_history")
	end,
}
