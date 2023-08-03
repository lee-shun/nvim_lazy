return {
	"L3MON4D3/LuaSnip",
	lazy = true,
	dependencies = {
		"rafamadriz/friendly-snippets",
		config = function()
			local snippet_path = vim.fn.stdpath("config") .. "/snip/"
			if not vim.tbl_contains(vim.opt.rtp:get(), snippet_path) then
				vim.opt.rtp:append(snippet_path)
			end

			-- Load snippets
			require("luasnip.loaders.from_vscode").lazy_load()
			-- require("luasnip.loaders.from_vscode").lazy_load({path = "./snip"})
		end,
	},
	config = function()
		local ls = require("luasnip")

		local types = require("luasnip.util.types")

		ls.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
			enable_autosnippets = true,
			ext_opts = {
				[types.choiceNode] = {
					active = {
						virt_text = { { "<-", "Error" } },
					},
				},
			},
		})

		ls.filetype_extend("all", { "_" })
	end,
}
