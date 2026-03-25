return {
	"hrsh7th/nvim-cmp",
	version = false, -- last release is way too old
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
					callback = function(ev)
						local paths = dict.ft[vim.bo.filetype] or {}
						vim.list_extend(paths, dict["*"])
						require("cmp_dictionary").setup({
							paths = paths,
						})
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

		cmp.setup({
			formatting = {
				format = function(entry, vim_item)
					-- Kind icons
					vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
					-- Source
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						buffer = "[Buf]",
						luasnip = "[Snip]",
						nvim_lua = "[Lua]",
						treesitter = "[TS]",
						path = "[Path]",
						nvim_lsp_signature_help = "[Sig]",
						cmp_tabnine = "[TN]",
                        dictionary = "[Dic]"
					})[entry.source.name]
					return vim_item
				end,
			},
		})

		cmp.setup({
			preselect = cmp.PreselectMode.None, -- 关闭自动选中
			completion = {
				completeopt = "menu,menuone,noinsert,noselect", -- 关键：禁用自动插入
			},
		})

		local has_words_before = function()
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
		end

		cmp.setup({
			enabled = function()
				-- disable autocompletion in telescope (wasn't playing good with telescope)
				local ftype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
				if ftype == "TelescopePrompt" then
					return false
				end

				local context = require("cmp.config.context")
				-- disable autocompletion in comments
				return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
			end,
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = {
				["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
				["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
				["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
				["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
				["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
				["<C-e>"] = cmp.mapping({ i = cmp.mapping.close(), c = cmp.mapping.close() }),
				["<CR>"] = cmp.mapping({
					i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
				}),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif has_words_before() then
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
			sources = {
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "path" },
				{ name = "cmp_tabnine" },
				{ name = "buffer" },
				{ name = "luasnip" },
				{ name = "treesitter" },
				{
					name = "dictionary",
					keyword_length = 2,
				},
			},
		})

		-- Use buffer source for `/`
		cmp.setup.cmdline("/", {
			sources = {
				{ name = "buffer" },
			},
		})

		-- Use cmdline & path source for ':'
		cmp.setup.cmdline(":", {
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})

		-- Auto pairs
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
	end,
}
