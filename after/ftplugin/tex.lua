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
    print("当前模式: " .. current_mode)
    print("视觉模式: " .. visual_mode)

    -- 处理 normal 模式（光标所在字符）
    if current_mode == "n" then
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local row, col = cursor_pos[1], cursor_pos[2]
        print(string.format("Normal 模式光标位置: row=%d, col=%d", row, col))

        local line = vim.api.nvim_get_current_line()
        print("当前行内容: " .. line)

        -- 获取光标下的字符
        local char = string.sub(line, col + 1, col + 1)
        print("光标下字符: " .. char)

        if char == "" then
            print("错误: 光标位置无效")
            return
        end

        -- 创建包裹后的文本
        local wrapped = pattern .. "{" .. char .. "}"
        print("包裹后文本: " .. wrapped)

        -- 替换文本
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col + 1, { wrapped })
        print("替换完成")

        -- 处理 visual 模式
    elseif current_mode:sub(1, 1) == "v" or current_mode:sub(1, 1) == "V" or current_mode == "\22" then
        print("进入 Visual 模式处理")

        -- 保存当前选区（在退出 Visual 模式前获取）
        local start_pos = vim.fn.getpos("v")
        local end_pos = vim.fn.getpos(".")
        print("视觉选择起点: (" .. start_pos[2] .. "," .. start_pos[3] .. ")")
        print("视觉选择终点: (" .. end_pos[2] .. "," .. end_pos[3] .. ")")

        local start_line, start_col = start_pos[2], start_pos[3]
        local end_line, end_col = end_pos[2], end_pos[3]

        -- 处理块选择 (Ctrl-V)
        if visual_mode == "\22" then
            print("块选择模式")
            -- 确保正确的选区方向
            if start_line > end_line then
                start_line, end_line = end_line, start_line
            end
            if start_col > end_col then
                start_col, end_col = end_col, start_col
            end

            print("调整后的块选区: 行[" .. start_line .. "-" .. end_line .. "], 列[" .. start_col .. "-" .. end_col .. "]")

            -- 从最后一行开始处理以避免行号变化
            for lnum = end_line, start_line, -1 do
                -- 安全获取行内容（处理最后一行问题）
                local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
                if not ok or #line == 0 then
                    print(string.format("警告: 行 %d 不存在或为空", lnum))
                    goto continue
                end
                line = line[1]

                print(string.format("处理行 %d: %s", lnum, line))

                -- 调整列索引（Lua 字符串是 1-based）
                local col_start = math.min(start_col, #line + 1)
                local col_end = math.min(end_col, #line)
                print(string.format("列范围: %d-%d", col_start, col_end))

                if col_start <= col_end then
                    local selected = string.sub(line, col_start, col_end)
                    print("选中文本: " .. selected)

                    local wrapped = pattern .. "{" .. selected .. "}"
                    print("包裹后: " .. wrapped)

                    -- 替换选中文本（单行处理，不会有多行问题）
                    vim.api.nvim_buf_set_text(0, lnum - 1, col_start - 1, lnum - 1, col_end, { wrapped })
                    print("行替换完成")
                end
                ::continue::
            end

            -- 处理行选择 (V)
        elseif visual_mode == "V" then
            print("行选择模式")
            -- 确保行顺序
            if start_line > end_line then
                start_line, end_line = end_line, start_line
            end

            print("调整后的行选区: 行[" .. start_line .. "-" .. end_line .. "]")

            -- 安全获取行内容（处理最后一行问题）
            local lines = {}
            for lnum = start_line, end_line do
                local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
                if ok and #line > 0 then
                    table.insert(lines, line[1])
                else
                    print(string.format("警告: 行 %d 不存在或为空", lnum))
                    table.insert(lines, "")
                end
            end

            local selected = table.concat(lines, "\n")
            print("选中文本: " .. selected)

            -- 创建包裹后文本
            local wrapped = pattern .. "{" .. selected .. "}"
            print("包裹后文本: " .. wrapped)

            -- 拆分包裹文本为多行
            local wrapped_lines = vim.split(wrapped, "\n", { plain = true })
            print("包裹后行数: " .. #wrapped_lines)

            -- 替换选中区域（整行替换）
            vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, wrapped_lines)
            print("替换完成")

            -- 处理字符选择 (v)
        else
            print("字符选择模式")
            -- 确保正确的选区方向
            if start_line > end_line or (start_line == end_line and start_col > end_col) then
                start_line, end_line = end_line, start_line
                start_col, end_col = end_col, start_col
            end

            print("调整后的选区: 行[" .. start_line .. "-" .. end_line .. "], 列[" .. start_col .. "-" .. end_col .. "]")

            -- 安全获取选中文本（处理最后一行问题）
            local lines = {}
            for lnum = start_line, end_line do
                local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
                if ok and #line > 0 then
                    line = line[1]
                else
                    print(string.format("警告: 行 %d 不存在或为空", lnum))
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
            print("选中文本: " .. selected)

            -- 创建包裹后文本
            local wrapped = pattern .. "{" .. selected .. "}"
            print("包裹后文本: " .. wrapped)

            -- 拆分包裹文本为多行
            local wrapped_lines = vim.split(wrapped, "\n", { plain = true })
            print("包裹后行数: " .. #wrapped_lines)

            -- 替换选中区域
            vim.api.nvim_buf_set_text(0, start_line - 1, start_col - 1,
                end_line - 1, end_col, wrapped_lines)
            print("替换完成")
        end

        -- 退出 Visual 模式
        vim.cmd("normal! \\<Esc>")
        print("已退出 Visual 模式")
    else
        print("错误: 不在 visual 或 normal 模式")
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
