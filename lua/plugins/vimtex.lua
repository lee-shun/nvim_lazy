return {
    "lervag/vimtex",
    lazy = false,
    -- ft = "tex",
    config = function()
        vim.g.latex_view_general_viewer = "zathura"
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_compiler_progname = "nvr"
        vim.g.vimtex_quickfix_mode = 0
        vim.g.vimtex_mappings_enabled = 0
        vim.g.vimtex_imaps_enabled = 0
        vim.g.vimtex_text_obj_enabled = 0
        vim.g.vimtex_fold_enabled = 0
        vim.g.tex_conceal = "abdmg"
        vim.g.vimtex_syntax_conceal_disable = 1
        vim.g.vimtex_format_enabled = 0
        vim.g.vimtex_syntax_enabled = 0
        vim.g.vimtex_compiler_silent = 1
        vim.g.tex_flavor = 'latex'
        vim.g.vimtex_compiler_method = 'latexmk'
        vim.cmd([[
        let g:vimtex_compiler_latexmk = {
            \ 'extra_options': '-xelatex -file-line-error -synctex=1 -shell-escape',
            \ 'callback' : 1,
            \ 'continuous' : 1,
            \}
            ]])
    end,
}
