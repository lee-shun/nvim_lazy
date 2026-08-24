return {
    "lervag/vimtex",
    ft = "tex",
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
        -- 关闭 vimtex 全部 conceal 特性：编辑时保持 LaTeX 原始符号。
        -- （旧版选项 g:tex_conceal 当前 vimtex 已不读取，已删；
        --   全局 conceallevel = 0 也保证任何来源的 conceal 都不显示）
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
