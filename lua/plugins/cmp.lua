return {
	"hrsh7th/nvim-cmp",
	version = false,
	event = "InsertEnter",
	dependencies = {
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "hrsh7th/cmp-cmdline" },
		{ "ray-x/cmp-treesitter" },
		{ "tzachar/cmp-tabnine", build = "./install.sh" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "hrsh7th/cmp-nvim-lsp-signature-help" },
		{ "lukas-reineke/cmp-under-comparator" },
		{ "L3MON4D3/LuaSnip" },
		{ "rafamadriz/friendly-snippets" },
		{
			"uga-rosa/cmp-dictionary",
			config = function()
				local dict = {
					["*"] = { "/usr/share/dict/words" },
					ft = {
						-- foo = { "/path/to/foo.dict" },
					},
				}
				require("cmp_dictionary").setup({
					paths = dict["*"],
					exact_length = 2,
					first_case_insensitive = true,
					document = {
						enable = false, -- 关闭 wn，避免 exit code 7
					},
				})

				vim.api.nvim_create_autocmd("BufEnter", {
					pattern = "*",
					callback = function()
						local paths = dict.ft[vim.bo.filetype] or {}
						vim.list_extend(paths, dict["*"])
						require("cmp_dictionary").setup({ paths = paths })
					end,
				})
			end,
		},
	},

	config = function()
		local cmp = require("cmp")

		local kind_icons = {
			Array = " ",
			Boolean = " ",
			Class = " ",
			Color = " ",
			Constant = " ",
			Constructor = " ",
			Copilot = " ",
			Enum = " ",
			EnumMember = " ",
			Event = " ",
			Field = " ",
			File = " ",
			Folder = " ",
			Function = " ",
			Interface = " ",
			Key = " ",
			Keyword = " ",
			Method = " ",
			Module = " ",
			Namespace = " ",
			Null = " ",
			Number = " ",
			Object = " ",
			Operator = " ",
			Package = " ",
			Property = " ",
			Reference = " ",
			Snippet = " ",
			String = " ",
			Struct = " ",
			Text = " ",
			TypeParameter = " ",
			Unit = " ",
			Value = " ",
			Variable = " ",
			TN = "💡",
		}

		-- ====================== 核心配置 ======================
		cmp.setup({
			preselect = cmp.PreselectMode.None,
			completion = {
				completeopt = "menu,menuone,noinsert,noselect",
			},

			enabled = function()
				local ftype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
				if ftype == "TelescopePrompt" then
					return false
				end
				return true -- 注释里也允许补全（方案二核心）
			end,

			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},

			mapping = {
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.close(),
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				}),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif require("cmp.config.has_words_before")() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s", "c" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					else
						fallback()
					end
				end, { "i", "s", "c" }),
			},

			formatting = {
				format = function(entry, vim_item)
					vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						nvim_lsp_signature_help = "[Sig]",
						luasnip = "[Snip]",
						cmp_tabnine = "[TN]",
						path = "[Path]",
						buffer = "[Buf]",
						treesitter = "[TS]",
						dictionary = "[Dic]",
					})[entry.source.name]
					return vim_item
				end,
			},

			sorting = {
				priority_weight = 2,
				comparators = {
					cmp.config.compare.offset,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					require("cmp-under-comparator").under,
					cmp.config.compare.kind,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},

			-- ====================== 注释里只保留部分源 ======================
			sources = {
				-- 普通代码使用的源（LSP 会自动在注释里被过滤掉）
				{
					name = "nvim_lsp",
					priority = 1000,
					max_item_count = 10,
					entry_filter = function(entry, ctx)
						local context = require("cmp.config.context")
						if context.in_treesitter_capture("comment") or context.in_syntax_group("Comment") then
							return false
						end
						return true
					end,
				},
				{
					name = "nvim_lsp_signature_help",
					priority = 950,
					max_item_count = 5,
					entry_filter = function(entry, ctx)
						local context = require("cmp.config.context")
						if context.in_treesitter_capture("comment") or context.in_syntax_group("Comment") then
							return false
						end
						return true
					end,
				},
				{ name = "luasnip", priority = 900, max_item_count = 5 },
				{ name = "cmp_tabnine", priority = 850, max_item_count = 5 },
				{ name = "path", priority = 800, max_item_count = 2 },
				{
					name = "buffer",
					priority = 700,
					option = {
						get_bufnrs = function()
							return vim.api.nvim_list_bufs()
						end,
						keyword_length = 3,
					},
					max_item_count = 5,
				},
				{ name = "treesitter", priority = 600, max_item_count = 5 },
				{
					name = "dictionary",
					priority = 500,
					keyword_length = 2,
					max_item_count = 10,
				},
			},
		})

		-- ====================== cmdline 配置 ======================
		cmp.setup.cmdline("/", {
			sources = { { name = "buffer" } },
		})
		cmp.setup.cmdline(":", {
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})

		-- ====================== nvim-autopairs ======================
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
	end,
}
