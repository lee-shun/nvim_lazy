return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "SmiteshP/nvim-navic" },
		{
			"smjonas/inc-rename.nvim",
			cmd = "IncRename",
			config = function()
				require("inc_rename").setup()
			end,
		},
		{
			"j-hui/fidget.nvim",
			config = true,
		},
	},
	config = function()
		local wk = require("which-key")

		local on_attach = function(client, bufnr)
			-- Enable completion triggered by <c-x><c-o>
			vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

			-- navic
			local navic = require("nvim-navic")
			if client.server_capabilities.documentSymbolProvider then
				navic.attach(client, bufnr)
				-- set navic
				vim.o.winbar = "%=%{%v:lua.require'nvim-navic'.get_location()%} "
			end

			-- mappings
			local keymap_g = {
				d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Definition" },
				D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Declaration" },
				H = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature help" },
				h = { "<cmd>LspUI hover<cr>", "LspUI Hover" },
				i = { "<cmd>Telescope lsp_implementations<cr>", "Goto implementation" },
				t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Goto type definition" },
				r = { "<cmd>lua vim.lsp.buf.references()<cr>", "Goto reference" },
			}
			wk.register(keymap_g, {
				mode = "n",
				prefix = "g",
				buffer = nil,
				silent = true,
				noremap = true,
				nowait = false,
			})

			-- diagnostic
			local keymap_l = {
				l = {
					name = "LSP",
					a = { "<cmd>LspUI code_action<cr>", "LspUI code action" },
					d = { "<cmd>lua vim.diagnostic.open_float()<cr>", "Diagnostic float" },
					i = {
						function()
							return ":IncRename " .. vim.fn.expand("<cword>")
						end,
						"IncRename",
						expr = true,
					},
					r = { "<cmd>LspUI rename<cr>", "LspUI rename" },
				},
			}
			wk.register(keymap_l, {
				mode = "n",
				prefix = "<leader>",
				buffer = nil,
				silent = true,
				noremap = true,
				nowait = false,
			})

			wk.register({
				["[d"] = { "<cmd>LspUI diagnostic prev<cr>", "LspUI prev diagnostic" },
				["]d"] = { "<cmd>LspUI diagnostic next<cr>", "LspUI next diagnostic" },
			}, {
				mode = "n",
				prefix = "",
				buffer = nil,
				silent = true,
				noremap = true,
				nowait = false,
			})
		end

		--
		-- cmp + lsp
		--
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}

		local cmp_cap = require("cmp_nvim_lsp").default_capabilities(capabilities)

		-- clangd
		local clangd_cap = cmp_cap
		clangd_cap.offsetEncoding = { "utf-16" }
		local clangd_on_attach = function(client, bufnr)
			local keymap_l = {
				l = {
					name = "LSP",
					j = { "<cmd>ClangdSwitchSourceHeader<cr>", "Clangd switch header" },
				},
			}
			wk.register(keymap_l, {
				mode = "n",
				prefix = "<leader>",
				buffer = nil,
				silent = true,
				noremap = true,
				nowait = false,
			})

			return on_attach(client, bufnr)
		end
		require("lspconfig")["clangd"].setup({
			on_attach = clangd_on_attach,
			capabilities = clangd_cap,
		})

		-- cmake
		require("lspconfig")["cmake"].setup({
			on_attach = on_attach,
			capabilities = cmp_cap,
		})

		-- pyright
		local pyright_cap = cmp_cap
		require("lspconfig")["pyright"].setup({
			on_attach = on_attach,
			capabilities = pyright_cap,
		})

		-- taxlab
		require("lspconfig")["texlab"].setup({
			on_attach = on_attach,
			capabilities = cmp_cap,
		})

		-- lua
		local runtime_path = vim.split(package.path, ";")
		table.insert(runtime_path, "lua/?.lua")
		table.insert(runtime_path, "lua/?/init.lua")

		require("lspconfig")["lua_ls"].setup({
			on_attach = on_attach,
			capabilities = cmp_cap,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
						path = runtime_path,
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false, -- THIS IS THE IMPORTANT LINE TO ADD
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		-- set icons (if not use lspsaga)
		local signs = { Error = "", Warn = "", Hint = " ", Info = "" }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end
	end,
}
