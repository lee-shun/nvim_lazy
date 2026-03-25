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
						enable = true,
						command = { "wn", "${label}", "-over" },
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
				local context = require("cmp.config.context")
				return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
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
					-- Kind icons
					vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
					-- Source name
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

			-- ====================== 排序优化（关键！） ======================
			sorting = {
				priority_weight = 2,
				comparators = {
					cmp.config.compare.offset,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					require("cmp-under-comparator").under, -- 你引入的 comparator
					cmp.config.compare.kind,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},

			-- ====================== 补全源 + 独立选项 + 优先级 ======================
			sources = {
				-- 1. LSP（最高优先级）
				{
					name = "nvim_lsp",
					priority = 1000,
					max_item_count = 10,
				},

				-- 2. Signature help
				{
					name = "nvim_lsp_signature_help",
					priority = 950,
					max_item_count = 5,
				},

				-- 3. Luasnip（片段）
				{
					name = "luasnip",
					priority = 900,
					max_item_count = 5,
					-- 可加：{ keyword_length = 2 } 等
				},

				-- 4. Tabnine（AI）
				{
					name = "cmp_tabnine",
					priority = 850,
   					max_item_count = 5,
					-- 可加：max_line = 1000 等（插件自身支持）
				},

				-- 5. Path
				{
					name = "path",
					priority = 800,
   					max_item_count = 2,
				},

				-- 6. Buffer（支持所有打开的 buffer，更实用）
				{
					name = "buffer",
					priority = 700,
					option = {
						get_bufnrs = function()
							return vim.api.nvim_list_bufs() -- 所有 buffer
						end,
						keyword_length = 3,
					},
   					max_item_count = 5,
				},

				-- 7. Treesitter
				{
					name = "treesitter",
					priority = 600,
   					max_item_count = 5,
				},

				-- 8. Dictionary（保留你原来的 keyword_length）
				{
					name = "dictionary",
					priority = 500,
					keyword_length = 2,
   					max_item_count = 5,
				},
			},
		})

		-- ====================== cmdline 配置（保持不变） ======================
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

		-- ====================== nvim-autopairs 集成 ======================
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
	end,
}
