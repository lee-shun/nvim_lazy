return {
	"ggml-org/llama.vim",
    events = "InsertEnter",
	init = function()
		vim.g.llama_config = {
			auto_fim = true,
			endpoint_fim = "http://127.0.0.1:8080/infill",
			keymap_fim_trigger = "<A-f>", -- Alt + f     手动触发 FIM 补全
			keymap_fim_accept_full = "<A-A>", -- Alt + a     接受完整补全
			keymap_fim_accept_line = "<A-a>", -- Alt + l     接受当前行
			keymap_fim_accept_word = "<A-w>", -- Alt + w     接受一个单词

			keymap_inst_trigger = "<A-i>", -- Alt + i     触发指令编辑
			keymap_inst_rerun = "<A-r>", -- Alt + r     重新运行
			keymap_inst_continue = "<A-c>", -- Alt + c     继续生成
			keymap_inst_accept = "<A-a>", -- Alt + a     接受指令编辑结果
			keymap_inst_cancel = "<A-x>", -- Alt + x     取消

			keymap_debug_toggle = "<A-d>", -- Alt + d     切换调试模式
		}
	end,
}
