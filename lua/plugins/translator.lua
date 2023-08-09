return {
	"voldikss/vim-translator",
	keys = { { "<leader>s", "<cmd>TranslateW<cr>", desc = "Translate" } },
	config = function()
		vim.cmd([[
        let g:translator_target_lang='zh'
        let g:translator_default_engines=['bing', 'haici', 'youdao']
        ]])
	end,
	cmd = "TranslateW",
}
