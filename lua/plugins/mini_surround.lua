return {
	"echasnovski/mini.surround",
	keys = function(_, keys)
		-- Populate the keys based on the user's options
		local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
		local opts = require("lazy.core.plugin").values(plugin, "opts", false)
		local mappings = {
			{ opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
			{ opts.mappings.delete, desc = "Delete surrounding" },
			{ opts.mappings.find, desc = "Find right surrounding" },
			{ opts.mappings.find_left, desc = "Find left surrounding" },
			{ opts.mappings.highlight, desc = "Highlight surrounding" },
			{ opts.mappings.replace, desc = "Replace surrounding" },
			{ opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
		}
		mappings = vim.tbl_filter(function(m)
			return m[1] and #m[1] > 0
		end, mappings)
		return vim.list_extend(mappings, keys)
	end,
	opts = {
		mappings = {
			add = "sa", -- Add surrounding in Normal and Visual modes
			delete = "sd", -- Delete surrounding
			find = "sf", -- Find surrounding (to the right)
			find_left = "sF", -- Find surrounding (to the left)
			highlight = "sh", -- Highlight surrounding
			replace = "sr", -- Replace surrounding
			update_n_lines = "sn", -- Update `n_lines`

			suffix_last = "l", -- Suffix to search with "prev" method
			suffix_next = "n", -- Suffix to search with "next" method
		},
	},
	config = function(_, opts)
		-- use gz mappings instead of s to prevent conflict with leap
		require("mini.surround").setup(opts)
	end,
}
