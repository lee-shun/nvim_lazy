return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"hrsh7th/nvim-cmp", -- 可选：slash commands
		"nvim-telescope/telescope.nvim", -- 可选
		"render-markdown.nvim",
	},
	cmd = { "CodeCompanion", "CodeCompanionCLI", "CodeCompanionChat", "CodeCompanionCmd", "CodeCompanionAction" },
	config = function()
		require("codecompanion").setup({
			adapters = {
				http = {
					["llama.cpp"] = function()
						return require("codecompanion.adapters").extend("openai_compatible", {
							env = {
								url = "http://192.168.1.105:8080", -- replace with your llama.cpp instance
								api_key = "TERM", -- placeholder value, can be any string
								chat_url = "/v1/chat/completions",
							},
							handlers = {
								parse_message_meta = function(self, data)
									local extra = data.extra
									if extra and extra.reasoning_content then
										data.output.reasoning = { content = extra.reasoning_content }
										if data.output.content == "" then
											data.output.content = nil
										end
									end
									return data
								end,
							},
						})
					end,
				},
			},
			interactions = {
				chat = {
					adapter = "llama.cpp",
				},
				inline = {
					adapter = "llama.cpp",
				},
			},
		})
	end,
}
