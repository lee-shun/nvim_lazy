vim.opt_local.textwidth = 80
vim.opt_local.spell = true

-- add keymaps
local buf = vim.api.nvim_get_current_buf()

require("which-key").add({
    {
        "<leader>rt",
        function()
            vim.cmd([[exec "vimtexstop"]])
            vim.cmd([[exec "vimtexcompile"]])
        end,
        buffer = buf,
        desc = "Recompile",
        nowait = false,
        remap = false
    },
    {
        "<leader>rv",
        function()
            vim.cmd([[exec "VimtexView"]])
        end,
        buffer = buf,
        desc = "View the pdf",
        nowait = false,
        remap = false
    },
})

function _G.wrap_with_pattern(pattern)
    -- 获取当前模式和视觉模式
    local current_mode = vim.fn.mode()
    local visual_mode = vim.fn.visualmode()

    -- 处理 normal 模式（光标所在字符）
    if current_mode == "n" then
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local row, col = cursor_pos[1], cursor_pos[2]

        local line = vim.api.nvim_get_current_line()

        -- 获取光标下的字符
        local char = string.sub(line, col + 1, col + 1)

        if char == "" then
            return
        end

        -- 创建包裹后的文本
        local wrapped = pattern .. "{" .. char .. "}"

        -- 替换文本
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col + 1, { wrapped })

        -- 处理 visual 模式
    elseif current_mode:sub(1, 1) == "v" or current_mode:sub(1, 1) == "V" or current_mode == "\22" then
        -- 保存当前选区（在退出 Visual 模式前获取）
        local start_pos = vim.fn.getpos("v")
        local end_pos = vim.fn.getpos(".")

        local start_line, start_col = start_pos[2], start_pos[3]
        local end_line, end_col = end_pos[2], end_pos[3]

        -- 处理字符选择 (v)
        if current_mode:sub(1, 1) == "v" then
            -- 确保正确的选区方向
            if start_line > end_line or (start_line == end_line and start_col > end_col) then
                start_line, end_line = end_line, start_line
                start_col, end_col = end_col, start_col
            end


            -- 安全获取选中文本（处理最后一行问题）
            local lines = {}
            for lnum = start_line, end_line do
                local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
                if ok and #line > 0 then
                    line = line[1]
                else
                    line = ""
                end

                -- 确定当前行的列范围
                local line_start_col, line_end_col
                if lnum == start_line then
                    line_start_col = math.min(start_col, #line + 1)
                else
                    line_start_col = 1
                end

                if lnum == end_line then
                    line_end_col = math.min(end_col, #line)
                else
                    line_end_col = #line
                end

                -- 添加当前行的选中部分
                if line_start_col <= line_end_col then
                    table.insert(lines, string.sub(line, line_start_col, line_end_col))
                else
                    table.insert(lines, "")
                end
            end

            local selected = table.concat(lines, "\n")

            -- 创建包裹后文本
            local wrapped = pattern .. "{" .. selected .. "}"

            -- 替换选中区域
            vim.api.nvim_buf_set_text(0, start_line - 1, start_col - 1,
                end_line - 1, end_col, { wrapped })
        end

        -- 退出 Visual 模式
        vim.cmd("normal! \\<Esc>")
    else
    end
end

require("which-key").add({
    {
        "<leader>bd",
        function()
            wrap_with_pattern("\\boldsymbol") -- 替换为你需要的模式
        end,
        buffer = buf,
        desc = "Bold",
        nowait = false,
        remap = false
    },
    {
        "<leader>bd",
        function()
            vim.cmd([[lua wrap_with_pattern("\\boldsymbol")]])
        end,
        buffer = buf,
        desc = "Bold",
        nowait = false,
        remap = false,
        mode = "v"
    }

})
