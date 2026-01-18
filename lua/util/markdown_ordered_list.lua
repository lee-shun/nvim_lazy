-- 在visual模式下切换有序列表的Lua函数
local function toggle_ordered_list()
    -- 获取当前模式
    local mode = vim.fn.mode()

    -- 检查是否在visual模式
    if not (mode:match("[vV]")) then
        vim.notify("此函数只能在visual模式下使用", vim.log.levels.WARN)
        return
    end

    -- 首先退出visual模式，确保选区被清除
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

    -- 等待模式切换完成
    vim.defer_fn(function()
        -- 获取之前visual选择的范围（需要在退出visual模式后立即获取）
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local start_line, start_col = start_pos[2], start_pos[3]
        local end_line, end_col = end_pos[2], end_pos[3]

        -- 确保起始位置在结束位置之前
        if start_line > end_line or (start_line == end_line and start_col > end_col) then
            start_line, end_line = end_line, start_line
            start_col, end_col = end_col, start_col
        end

        -- 获取当前buffer
        local bufnr = vim.api.nvim_get_current_buf()

        -- 获取选中的行
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

        if #lines == 0 then
            return
        end

        -- 检查选中的行是否都是有序列表
        local all_ordered = true
        local list_pattern = "^%s*(%d+)[%.%)]%s+"
        local chinese_pattern = "^%s*(%d+)[、.]%s+"

        for i, line in ipairs(lines) do
            -- 检查是否为有序列表（支持中文和英文格式）
            local is_ordered = line:match(list_pattern) or line:match(chinese_pattern)
            if not is_ordered then
                all_ordered = false
                break
            end
        end

        -- 根据检查结果进行切换
        local new_lines = {}

        if all_ordered then
            -- 移除有序列表标记
            for i, line in ipairs(lines) do
                -- 尝试匹配英文格式
                local new_line = line:gsub("^(%s*)(%d+)[%.%)]%s+", "%1")
                if new_line == line then
                    -- 如果不是英文格式，尝试匹配中文格式
                    new_line = line:gsub("^(%s*)(%d+)[、.]%s+", "%1")
                end
                table.insert(new_lines, new_line)
            end
        else
            -- 添加有序列表标记
            for i, line in ipairs(lines) do
                -- 检查当前行是否已有列表标记
                local has_mark = line:match(list_pattern) or line:match(chinese_pattern)

                if not has_mark then
                    -- 找到第一个非空白字符的位置
                    local indent = line:match("^(%s*)")
                    local content = line:sub(#indent + 1)

                    -- 添加有序列表标记（支持中文和英文格式）
                    -- 可以选择中文或英文格式，这里默认使用中文格式
                    local list_mark = string.format("%d. ", i)
                    table.insert(new_lines, indent .. list_mark .. content)
                else
                    -- 如果已经有标记，保持原样
                    table.insert(new_lines, line)
                end
            end
        end

        -- 替换选中的行
        vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, new_lines)

        -- 清除visual选择标记，避免影响下一次选择
        vim.fn.setpos("'<", { 0, 0, 0, 0 })
        vim.fn.setpos("'>", { 0, 0, 0, 0 })

        -- 移动到操作区域的开始位置
        vim.api.nvim_win_set_cursor(0, { start_line, 0 })
    end, 10)
end

-- 设置按键映射
vim.keymap.set('v', '<leader>mn', toggle_ordered_list, {
    noremap = true,
    silent = true,
    desc = '切换有序列表'
})

-- 可选：也支持normal模式下的多行操作
local function toggle_ordered_list_normal()
    -- 进入visual行选择模式
    vim.cmd("normal! V")
    -- 等待进入visual模式
    vim.defer_fn(function()
        toggle_ordered_list()
    end, 10)
end

-- 为normal模式也创建一个映射（可选）
vim.keymap.set('n', '<leader>mn', toggle_ordered_list_normal, {
    noremap = true,
    silent = true,
    desc = '切换当前行为有序列表'
})
