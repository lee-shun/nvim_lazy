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
    local visual_mode = vim.fn.mode()

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

        -- 处理块选择 (Ctrl-V) - 每行独立包裹
        if visual_mode == "\22" then
            -- 确保正确的选区方向
            if start_line > end_line then
                start_line, end_line = end_line, start_line
            end
            if start_col > end_col then
                start_col, end_col = end_col, start_col
            end


            -- 从最后一行开始处理以避免行号变化
            for lnum = end_line, start_line, -1 do
                -- 安全获取行内容（处理最后一行问题）
                local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
                if not ok or #line == 0 then
                    -- 对于空行，直接插入包裹的空文本
                    local wrapped_empty = pattern .. "{}"
                    vim.api.nvim_buf_set_text(0, lnum - 1, start_col - 1, lnum - 1, start_col - 1, { wrapped_empty })
                    goto continue
                end
                line = line[1]


                -- 调整列索引（Lua 字符串是 1-based）
                local col_start = math.min(start_col, #line + 1)
                local col_end = math.min(end_col, #line)

                if col_start <= col_end then
                    local selected = string.sub(line, col_start, col_end)

                    local wrapped = pattern .. "{" .. selected .. "}"

                    -- 替换选中文本（单行处理）
                    vim.api.nvim_buf_set_text(0, lnum - 1, col_start - 1, lnum - 1, col_end, { wrapped })
                else
                    -- 处理空选择（选择范围在行尾之后）
                    local wrapped_empty = pattern .. "{}"
                    vim.api.nvim_buf_set_text(0, lnum - 1, col_start - 1, lnum - 1, col_start - 1, { wrapped_empty })
                end
                ::continue::
            end

            -- 处理行选择 (V) - 整体包裹
        elseif visual_mode == "V" then
            -- 确保行顺序
            if start_line > end_line then
                start_line, end_line = end_line, start_line
            end


            -- 安全获取行内容（处理最后一行问题）
            local lines = {}
            for lnum = start_line, end_line do
                local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
                if ok and #line > 0 then
                    table.insert(lines, line[1])
                else
                    table.insert(lines, "") -- 空行用空字符串表示
                end
            end

            local selected = table.concat(lines, "\n")

            -- 创建包裹后文本（整体包裹）
            local wrapped = pattern .. "{" .. selected .. "}"

            -- 拆分包裹文本为多行
            local wrapped_lines = vim.split(wrapped, "\n", { plain = true })

            -- 替换选中区域（整行替换）
            vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, wrapped_lines)

            -- 处理字符选择 (v) - 整体包裹
        else
            -- 确保正确的选区方向
            if start_line > end_line or (start_line == end_line and start_col > end_col) then
                start_line, end_line = end_line, start_line
                start_col, end_col = end_col, start_col
            end


            -- 安全获取选中文本（处理最后一行问题）
            local lines = {}
            for lnum = start_line, end_line do
                local ok, line_content = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
                if ok and #line_content > 0 then
                    line_content = line_content[1]
                else
                    line_content = ""
                end

                -- 确定当前行的列范围
                local line_start_col, line_end_col
                if lnum == start_line then
                    line_start_col = math.min(start_col, #line_content + 1)
                else
                    line_start_col = 1
                end

                if lnum == end_line then
                    line_end_col = math.min(end_col, #line_content)
                else
                    line_end_col = #line_content
                end

                -- 添加当前行的选中部分
                if line_start_col <= line_end_col then
                    table.insert(lines, string.sub(line_content, line_start_col, line_end_col))
                else
                    table.insert(lines, "") -- 空选择
                end
            end

            -- 将多行内容合并为单个字符串（整体包裹）
            local selected = table.concat(lines, "\n")

            -- 创建包裹后文本（整体包裹）
            local wrapped = pattern .. "{" .. selected .. "}"

            -- 拆分包裹文本为多行
            local wrapped_lines = vim.split(wrapped, "\n", { plain = true })

            -- 替换选中区域
            vim.api.nvim_buf_set_text(0, start_line - 1, start_col - 1,
                end_line - 1, end_col, wrapped_lines)
        end
    else
    end
end

require("which-key").add({
    {
        "<leader>bd",
        function()
            wrap_with_pattern("\\boldsymbol") -- 替换为你需要的模式
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes('<Esc>', true, false, true),
                'n',
                false
            )
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
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes('<Esc>', true, false, true),
                'n',
                false
            )
        end,
        buffer = buf,
        desc = "Bold",
        nowait = false,
        remap = false,
        mode = "v"
    }

})
