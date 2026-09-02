return {
	"alex35mil/pi.nvim",
	event = "VeryLazy",
	dependencies = {
		-- 可选：剪贴板贴图
		"HakonHarnes/img-clip.nvim",
	},
	config = function()
		require("pi").setup({
            show_thinking = true,
		})

		-- ============================================
		-- which-key 键位组织
		-- ============================================
		local wk = require("which-key")
		local pi = require("pi")

		-- ── 全局键位（<leader>p 前缀）──
		wk.add({
			{ "<leader>p", group = "π Pi Agent", icon = "󰚩" },

			{
				"<leader>pp",
				function()
					vim.cmd("Pi layout=side")
				end,
				desc = "Open side panel",
			},
			{
				"<leader>pf",
				function()
					vim.cmd("Pi layout=float")
				end,
				desc = "Open float",
			},
			{ "<leader>pt", "<Cmd>PiToggleChat<CR>", desc = "Toggle chat" },
			{ "<leader>pl", "<Cmd>PiToggleLayout<CR>", desc = "Toggle layout" },
			{ "<leader>pc", "<Cmd>PiContinue<CR>", desc = "Continue last session" },
			{ "<leader>pr", "<Cmd>PiResume<CR>", desc = "Resume past session" },
			{ "<leader>pm", "<Cmd>PiSendMention<CR>", desc = "Mention file/selection" },
			{ "<leader>pa", "<Cmd>PiAttention<CR>", desc = "Next attention request" },
			{ "<leader>pn", "<Cmd>PiNewSession<CR>", desc = "New session" },
			{ "<leader>px", "<Cmd>PiCompact<CR>", desc = "Compact context" },
		})

		-- ── π 面板内共享键位（buffer-local）──
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("pi-whichkey", { clear = true }),
			pattern = { "pi-chat-history", "pi-chat-prompt", "pi-chat-attachments" },
			callback = function(args)
				local buf = args.buf

				wk.add({
					{ "<C-q>", "<Cmd>PiToggleChat<CR>", desc = "Toggle chat", buffer = buf },
					{ "<M-c>", "<Cmd>PiAbort<CR>", desc = "Abort agent", buffer = buf },
					{ "<C-o>", pi.toggle_history_blocks, desc = "Toggle blocks", buffer = buf },
				}, { buffer = buf })
			end,
		})

		-- ── Prompt 窗口专属键位 ──
		vim.api.nvim_create_autocmd("FileType", {
			group = "pi-whichkey",
			pattern = "pi-chat-prompt",
			callback = function(args)
				local buf = args.buf

				wk.add({
					-- 面板导航
					{ "<S-Up>", pi.focus_chat_history, desc = "Focus history", buffer = buf },
					{ "<S-Down>", pi.focus_chat_attachments, desc = "Focus attachments", buffer = buf },

					-- 历史滚动（不离开 prompt）
					{
						"<C-Up>",
						function()
							pi.scroll_chat_history("up", 2)
						end,
						desc = "Scroll history up",
						buffer = buf,
					},
					{
						"<C-Down>",
						function()
							pi.scroll_chat_history("down", 2)
						end,
						desc = "Scroll history down",
						buffer = buf,
					},

					-- 模型 & 思考级别
					{ "<M-m>", pi.cycle_model, desc = "Cycle model", buffer = buf },
					{ "<M-M>", pi.select_model, desc = "Select model", buffer = buf },
					{ "<M-t>", pi.cycle_thinking_level, desc = "Cycle thinking level", buffer = buf },
					{ "<M-T>", pi.select_thinking_level, desc = "Select thinking level", buffer = buf },

					-- 会话 & Zen
					{ "<M-n>", pi.new_session, desc = "New session", buffer = buf },
					{ "<M-x>", pi.compact, desc = "Compact", buffer = buf },

					-- 附件
					{ "<C-v>", pi.paste_image, desc = "Paste image", buffer = buf },
				}, { buffer = buf })
			end,
		})

		-- ── History 窗口专属键位 ──
		vim.api.nvim_create_autocmd("FileType", {
			group = "pi-whichkey",
			pattern = "pi-chat-history",
			callback = function(args)
				local buf = args.buf
				wk.add({
					{ "<S-Down>", pi.focus_chat_prompt, desc = "Focus prompt", buffer = buf },
				}, { buffer = buf })
			end,
		})

		-- ── Attachments 窗口专属键位 ──
		vim.api.nvim_create_autocmd("FileType", {
			group = "pi-whichkey",
			pattern = "pi-chat-attachments",
			callback = function(args)
				local buf = args.buf
				wk.add({
					{ "<S-Up>", pi.focus_chat_prompt, desc = "Focus prompt", buffer = buf },
					{ "<C-v>", pi.paste_image, desc = "Paste image", buffer = buf },
				}, { buffer = buf })
			end,
		})
	end,
}
