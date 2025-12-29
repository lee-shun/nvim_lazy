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

                silent exec "!" . l:browser . " --password-store=gnome --new-window " . a:url . " &"
        endfunction
            ]])
        -- vim.g.mkdp_browser = "microsoft-edge-dev"
        vim.g.mkdp_browserfunc = "g:Open_browser"
    end,
}
