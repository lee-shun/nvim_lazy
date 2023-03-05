return {
	"iamcco/markdown-preview.nvim",
	build = ":call mkdp#util#install()",
	ft = { "markdown" },
	config = function()
		vim.cmd([[
            function! g:Open_browser(url)
            silent exec "!google-chrome --password-store=gnome --new-window " . a:url . " &"
            endfunction
            ]])
		vim.g.mkdp_browser = "google-chrome"
		vim.g.mkdp_browserfunc = "g:Open_browser"
	end,
}
