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
        vim.g.tex_conceal = "abdmg"
        vim.g.vimtex_syntax_conceal_disable = 1
        -- 全局 conceallevel = 0（options.lua）会让 tex_conceal 失效：
        -- 0.11+ 起 conceallevel 是 window-local，这里按窗口内 buffer 的
        -- filetype 设置：tex 窗口恢复 conceal，其他窗口保持全局默认。
        -- 注意：设窗口值会污染 vim.go 的读取，所以默认值必须在改动前捕获
        local default_level = vim.go.conceallevel
        local function apply_conceal(win, buf)
            local level = default_level
            if vim.bo[buf].filetype == "tex" then
                level = 2
            end
            vim.api.nvim_set_option_value("conceallevel", level, { win = win })
        end
        apply_conceal(0, 0)
        vim.api.nvim_create_autocmd("BufWinEnter", {
            callback = function(event)
                apply_conceal(event.win, event.buf)
            end,
        })
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
