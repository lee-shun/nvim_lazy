return {
	"echasnovski/mini.ai",
	event = "VeryLazy",
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			init = function()
				-- no need to load the plugin, since we only need its queries
				require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
			end,
		},
	},
	opts = function()
		local ai = require("mini.ai")
		return {
			n_lines = 500,
			custom_textobjects = {
				o = ai.gen_spec.treesitter({
					a = { "@block.outer", "@conditional.outer", "@loop.outer" },
					i = { "@block.inner", "@conditional.inner", "@loop.inner" },
				}, {}),
				f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
				c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
			},
		}
	end,
	config = function(_, opts)
		require("mini.ai").setup(opts)
		-- register all text objects with which-key
		local i = {
			-- build-in
			[" "] = "Whitespace",
			['"'] = 'Balanced "',
			[","] = "Balanced ,",
			["."] = "Balanced .",
			[";"] = "Balanced ;",
			[":"] = "Balanced :",
			["'"] = "Balanced '",
			["`"] = "Balanced `",
			["("] = "Balanced (",
			[")"] = "Balanced ) including white-space",
			[">"] = "Balanced > including white-space",
			["<lt>"] = "Balanced <",
			["]"] = "Balanced ] including white-space",
			["["] = "Balanced [",
			["}"] = "Balanced } including white-space",
			["{"] = "Balanced {",
			["?"] = "User Prompt",
			a = "Argument",
			q = "Quote `, \", '",
			b = "Balanced ), ], }",
			t = "Tag",

			-- treesitter-text-obj
			c = "Class",
			f = "Function",
			o = "Block, conditional, loop",
		}
		local a = vim.deepcopy(i)
		for k, v in pairs(a) do
			a[k] = v:gsub(" including.*", "")
		end

		local ic = vim.deepcopy(i)
		local ac = vim.deepcopy(a)
		for key, name in pairs({ n = "Next", l = "Last" }) do
			i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
			a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
		end
		-- NOTE: which-key also names the vim buildin text-obj, update part of
		-- them
		require("which-key").register({
			mode = { "o", "x" },
			i = i,
			a = a,
		})
	end,
}
