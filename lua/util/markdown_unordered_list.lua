-- 在visual模式下切换无序列表的Lua函数
local function toggle_unordered_list()
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
        -- 获取之前visual选择的范围
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

        -- 定义无序列表的多种标记模式
        local unordered_patterns = {
            -- 英文格式
            "^%s*[-*+]%s+",
            -- 中文格式
            "^%s*[•·●○■□▶]%s+",
            "^%s*[、]%s+",
            -- Markdown格式
            "^%s*%-%s+",
            "^%s*%*%s+",
            "^%s*%+%s+",
        }

        -- 检查选中的行是否都是无序列表
        local all_unordered = true

        for _, line in ipairs(lines) do
            local is_unordered = false

            -- 检查是否匹配任意无序列表模式
            for _, pattern in ipairs(unordered_patterns) do
                if line:match(pattern) then
                    is_unordered = true
                    break
                end
            end

            if not is_unordered then
                all_unordered = false
                break
            end
        end

        -- 根据检查结果进行切换
        local new_lines = {}

        if all_unordered then
            -- 移除无序列表标记
            for _, line in ipairs(lines) do
                local new_line = line

                -- 尝试所有模式进行匹配移除
                for _, pattern in ipairs(unordered_patterns) do
                    -- 使用gsub移除标记，但保留缩进
                    new_line = new_line:gsub("^(%s*)[-*+•·●○■□▶、]%s+", "%1")
                end

                table.insert(new_lines, new_line)
            end
        else
            -- 添加无序列表标记
            for _, line in ipairs(lines) do
                -- 检查当前行是否已有列表标记
                local has_mark = false

                for _, pattern in ipairs(unordered_patterns) do
                    if line:match(pattern) then
                        has_mark = true
                        break
                    end
                end

                if not has_mark then
                    -- 找到缩进
                    local indent = line:match("^(%s*)")
                    local content = line:sub(#indent + 1)

                    -- 获取文件类型以决定使用哪种标记
                    local filetype = vim.bo.filetype
                    local list_mark

                    if filetype == "markdown" then
                        -- Markdown使用标准格式
                        list_mark = "- "
                    elseif filetype == "org" then
                        -- Org模式使用特定格式
                        list_mark = "- "
                    else
                        -- 其他文件类型使用中文常用格式
                        list_mark = "• "
                    end

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
vim.keymap.set('v', '<leader>mu', toggle_unordered_list, {
    noremap = true,
    silent = true,
    desc = '切换无序列表'
})

-- 可选：也支持normal模式下的单行操作
local function toggle_unordered_list_normal()
    -- 进入visual行选择模式
    vim.cmd("normal! V")
    -- 等待进入visual模式
    vim.defer_fn(function()
        toggle_unordered_list()
    end, 10)
end

-- 为normal模式也创建一个映射（可选）
vim.keymap.set('n', '<leader>mu', toggle_unordered_list_normal, {
    noremap = true,
    silent = true,
    desc = '切换当前行为无序列表'
})

-- 高级版本：带有多层缩进支持的无序列表切换
local function toggle_unordered_list_with_indent()
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
        -- 获取之前visual选择的范围
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

        -- 支持的多级列表标记（根据缩进层级使用不同标记）
        -- local bullet_types = {
        --     "• ", -- 第一级
        --     "  ◦ ", -- 第二级
        --     "    ▪ ", -- 第三级
        --     "      ▸ ", -- 第四级
        -- }
        local bullet_types = {
            "- ",
            "  - ",
            "    - ",
            "      - ",
        }

        -- 检查选中的行是否都是无序列表
        local all_unordered = true
        local bullet_pattern = "^%s*[-*+•·●○■□▶、]%s+"

        for _, line in ipairs(lines) do
            if not line:match(bullet_pattern) then
                all_unordered = false
                break
            end
        end

        -- 根据检查结果进行切换
        local new_lines = {}

        if all_unordered then
            -- 移除无序列表标记
            for _, line in ipairs(lines) do
                local new_line = line:gsub("^(%s*)[-*+•·●○■□▶、]%s+", "%1")
                table.insert(new_lines, new_line)
            end
        else
            -- 添加无序列表标记，根据缩进层级使用不同的标记
            for _, line in ipairs(lines) do
                -- 检查当前行是否已有列表标记
                local has_mark = line:match(bullet_pattern)

                if not has_mark then
                    -- 计算缩进层级（每2个空格或1个制表符为一级）
                    local indent = line:match("^(%s*)")
                    local indent_level = math.floor(#indent / 2) + 1

                    -- 选择对应的标记（如果超过层级，使用最后一种）
                    local bullet_type = bullet_types[math.min(indent_level, #bullet_types)] or
                        bullet_types[#bullet_types]

                    -- 移除原有的缩进，添加带层级的标记
                    local content = line:sub(#indent + 1)

                    -- 根据缩进层级决定使用多少空格
                    local new_indent = string.rep("  ", indent_level - 1) -- 每一级2个空格

                    table.insert(new_lines, new_indent .. bullet_type:gsub("^%s*", "") .. content)
                else
                    -- 如果已经有标记，保持原样
                    table.insert(new_lines, line)
                end
            end
        end

        -- 替换选中的行
        vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, new_lines)

        -- 清除visual选择标记
        vim.fn.setpos("'<", { 0, 0, 0, 0 })
        vim.fn.setpos("'>", { 0, 0, 0, 0 })

        -- 移动到操作区域的开始位置
        vim.api.nvim_win_set_cursor(0, { start_line, 0 })
    end, 10)
end

-- 可选的高级版本映射
vim.keymap.set('v', '<leader>mU', toggle_unordered_list_with_indent, {
    noremap = true,
    silent = true,
    desc = '切换无序列表（支持缩进层级）'
})
