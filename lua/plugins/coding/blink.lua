return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	dependencies = {
		-- snippet 引擎：luasnip.lua 已自带 InsertEnter 触发，
		-- 此依赖边仅保证 LuaSnip 先于 blink 的 config 加载（snippets preset 依赖它）
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets",
		-- 兼容层：让 nvim-cmp 生态的源跑在 blink.cmp 上
		{ "saghen/blink.compat", version = "2.*", lazy = true, opts = {} },
		-- 词典补全（原 cmp-dictionary，源名 "dictionary"）
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
		local kind_icons = require("util.icons").kinds

		-- ====================== 辅助函数 ======================
		local has_words_before = function()
			-- 兼容 LuaJIT / Neovim 内置 Lua 5.1
			local unpack = unpack or table.unpack

			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
		end

		-- 判断光标是否在注释里（复刻原 cmp 的 context.in_treesitter_capture("comment") 逻辑）
		local in_comment = function()
			local ok, captures = pcall(vim.treesitter.get_captures_at_cursor, 0)
			if ok and type(captures) == "table" then
				for _, cap in ipairs(captures) do
					if type(cap) == "table" and cap.capture and cap.capture:find("comment", 1, true) then
						return true
					end
				end
			end
			-- 无 treesitter 时回退到 syntax
			local syn = vim.tbl_filter(function(id)
				return vim.fn.synIDattr(id, "name"):find("Comment") ~= nil
			end, vim.fn.synstack(vim.fn.line("."), vim.fn.col(".")))
			return #syn > 0
		end

		require("blink.cmp").setup({
			-- ====================== 补全列表 ======================
			completion = {
				-- preselect = false：不预选（Enter 需显式选择后才确认）
				-- auto_insert = true：Tab/S-Tab（及 C-n/C-p）导航时自动填充选中项，无需按 Enter
				list = {
					selection = {
						preselect = false,
						auto_insert = true,
					},
				},
				menu = {
					auto_show = true,
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "source" },
						},
						components = {
							kind_icon = {
								text = function(ctx)
									return kind_icons[ctx.kind] or ""
								end,
							},
							source = {
								text = function(ctx)
									return ({
										lsp = "[LSP]",
										snippets = "[Snip]",
										path = "[Path]",
										buffer = "[Buf]",
										dictionary = "[Dic]",
									})[ctx.source_id] or ""
								end,
							},
						},
					},
				},
				-- 确认补全项时的括号处理（内置 auto_brackets，替代 nvim-autopairs 的 cmp 集成）
				accept = {
					auto_brackets = {
						enabled = true,
						-- 复刻原 map_char = { tex = "" }：tex 中确认时自动加括号
						override_brackets_for_filetypes = {
							tex = {},
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 250,
				},
			},

			-- signature help（替代原 nvim_lsp_signature_help 源）
			signature = { enabled = true },

			-- 无 cargo/rust 环境：blink 默认走纯 Lua 模糊匹配，frecency 需要 Rust 库，显式关闭
			fuzzy = {
				frecency = { enabled = false },
			},

			-- LuaSnip 作为 snippet 引擎
			snippets = { preset = "luasnip" },

			-- ====================== 键位 ======================
			keymap = {
				preset = "default",
				["<C-p>"] = { "select_prev", "fallback_to_mappings" },
				["<C-n>"] = { "select_next", "fallback_to_mappings" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-e>"] = { "hide", "fallback" },
				-- 复刻原 cmp：Enter 仅在明确选中项时确认（Replace），否则普通回车
				["<CR>"] = {
					function(cmp)
						if cmp.is_visible() and cmp.get_selected_item() ~= nil then
							return cmp.accept()
						end
						return false -- 无选中项 → 继续链 → 'fallback'
					end,
					"fallback",
				},
				-- 复刻原 cmp Tab：可见→下一个 / 有词→触发补全 / 否则 fallback
				["<Tab>"] = {
					function(cmp)
						if cmp.is_visible() then
							return cmp.select_next()
						elseif has_words_before() then
							return cmp.show()
						end
						return false -- 无词 → 继续链 → 'fallback'
					end,
					"fallback",
				},
				["<S-Tab>"] = {
					function(cmp)
						if cmp.is_visible() then
							return cmp.select_prev()
						end
						return false -- 不可见 → 继续链 → 'fallback'
					end,
					"fallback",
				},
			},

			-- ====================== 源 ======================
			sources = {
				default = { "lsp", "snippets", "path", "buffer", "dictionary" },
				-- 与旧 cmp 一致：TelescopePrompt 中禁用补全
				per_filetype = {
					TelescopePrompt = {},
					-- π prompt 窗口：启用 pi.nvim 原生 blink 源（@mentions / /commands）
					["pi-chat-prompt"] = { "pi" },
					-- Avante 输入框：仅启用 avante 的补全源（原 avante 通过 cmp.setup.filetype 配置）
					AvanteInput = { "avante_commands", "avante_mentions", "avante_shortcuts", "avante_files" },
					AvantePromptInput = { "avante_prompt_mentions" },
				},
				providers = {
					-- LSP：注释里自动过滤（原 entry_filter 逻辑）
					lsp = {
						enabled = function()
							return not in_comment()
						end,
						score_offset = 100,
						max_items = 10,
					},
					snippets = {
						score_offset = 90,
						max_items = 5,
					},
					path = {
						score_offset = 80,
						max_items = 2,
					},
					buffer = {
						score_offset = 70,
						max_items = 5,
						min_keyword_length = 3,
						opts = {
							get_bufnrs = function()
								return vim.api.nvim_list_bufs()
							end,
						},
					},
					-- ── 经 blink.compat 桥接的 nvim-cmp 源 ──
					dictionary = {
						name = "dictionary", -- cmp-dictionary 注册的源名
						module = "blink.compat.source",
						score_offset = 50,
						max_items = 10,
						min_keyword_length = 2,
					},
					-- ── Avante 补全源（经 blink.compat 桥接，原 avante 依赖 nvim-cmp）──
					avante_commands = {
						name = "avante_commands",
						module = "blink.compat.source",
						score_offset = 90,
						opts = {},
					},
					avante_files = {
						name = "avante_files",
						module = "blink.compat.source",
						score_offset = 100,
						opts = {},
					},
					avante_mentions = {
						name = "avante_mentions",
						module = "blink.compat.source",
						score_offset = 1000,
						opts = {},
					},
					avante_shortcuts = {
						name = "avante_shortcuts",
						module = "blink.compat.source",
						score_offset = 1000,
						opts = {},
					},
					avante_prompt_mentions = {
						name = "avante_prompt_mentions",
						module = "blink.compat.source",
						score_offset = 1000,
						opts = {},
					},
					-- pi.nvim 自带原生 blink 源（@ / /  / . 自动触发）
					pi = { name = "Pi", module = "pi.completion.blink" },
				},
			},

			-- ====================== cmdline 补全 ======================
			-- 复刻原 cmp.setup.cmdline：/ 用 buffer，: 用 cmdline + path
			cmdline = {
				enabled = true,
				keymap = { preset = "cmdline" },
				sources = function()
					local type = vim.fn.getcmdtype()
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					return { "cmdline", "path" }
				end,
				completion = {
					-- 默认仅在 cmdwin（<C-f>）里自动弹出；改为在命令行里也自动弹出
					menu = { auto_show = true },
				},
			},
		})
	end,
}
