return {
    "iamcco/markdown-preview.nvim",
    build = ":call mkdp#util#install()",
    ft = { "markdown" },
    config = function()
        vim.cmd([[
        function! g:Open_browser(url)
            if executable("/home/ls/App/zen/zen")
                let l:browser= "/home/ls/App/zen/zen"
            elseif executable("microsoft-edge-dev")
                let l:browser= "microsoft-edge-dev"
            elseif executable("microsoft-edge")
                let l:browser= "microsoft-edge"
            elseif executable("google-chrome")
                let l:browser= "google-chrome"
            else
                echo "need edge or chrome to be installed."
                return
            endif

                silent exec "!" . l:browser . " --password-store=gnome --new-tab " . a:url . " &"
        endfunction
            ]])


        vim.g.mkdp_browserfunc = "g:Open_browser"
        -- vim.g.mkdp_browser = '/home/ls/App/zen/zen'
        vim.g.mkdp_auto_start = 0
        vim.g.mkdp_auto_close = 0
        vim.g.mkdp_combine_preview = 1
    end,
}
