vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.spell = true

local buf = vim.api.nvim_get_current_buf()

require("which-key").add({
    "<leader>rm",
    function()
        vim.cmd([[exec "MarkdownPreview" ]])
    end
    ,
    buffer = buf,
    desc = "Preview",
    nowait = false,
    remap = false
})

-- 定义插入时间的函数
function _G.insert_formatted_time()
    local time_str = os.date("%Y-%m-%d  %H:%M:%S")    -- 格式化时间字符串[2](), [4]()
    local cursor_pos = vim.api.nvim_win_get_cursor(0) -- 获取光标位置
    local row = cursor_pos[1] - 1                     -- 行号(0-indexed)
    local col = cursor_pos[2]                         -- 列号(0-indexed)

    -- 在光标位置插入时间字符串
    vim.api.nvim_buf_set_text(0, row, col, row, col, { time_str }) -- 缓冲区操作[8]()

    -- 更新光标位置到插入内容后
    vim.api.nvim_win_set_cursor(0, { cursor_pos[1], col + #time_str })
end

vim.keymap.set('i', '<C-t>', '<cmd>lua insert_formatted_time()<CR>', { noremap = true, silent = true })
require("which-key").add({
    {
        "<C-t>",
        '<cmd>lua insert_formatted_time()<CR>',
        buffer = buf,
        desc = "insert_formatted_time",
        nowait = false,
        remap = false,
        mode = "i"
    }

})

-- 定义插入时间的函数（复用历史功能）
function _G.insert_time()
    return os.date("%Y-%m-%d  %H:%M:%S")
end

-- 更新Frontmatter日期的核心函数
function _G.update_frontmatter_date(pattern)
    if vim.bo.filetype ~= "markdown" then return end

    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local in_frontmatter = false
    local date_updated = false
    local frontmatter_end = 0

    -- 默认匹配模式（若未传入参数）
    pattern = pattern or "date"

    -- 扫描缓冲区定位Frontmatter区域
    for i, line in ipairs(buf_lines) do
        if line:match("^%-%-%-$") then
            if in_frontmatter then
                frontmatter_end = i
                break
            else
                in_frontmatter = true
            end
        end

        -- 在Frontmatter内搜索目标字段
        if in_frontmatter and line:match("^" .. pattern..":") then
            local new_time = os.date("%Y-%m-%d  %H:%M:%S")
            buf_lines[i] = pattern ..":" .. " " .. new_time
            date_updated = true
        end
    end

    -- 若找到匹配字段则更新缓冲区
    if date_updated then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, buf_lines)
        vim.cmd("write") -- 自动保存[4]()
        vim.notify("Updated  '" .. pattern .. "' to current time", vim.log.levels.INFO)
    end
end

-- 可选：手动更新命令
vim.api.nvim_create_user_command("UpdateDate", function()
    _G.update_frontmatter_date()
end, {})
vim.api.nvim_create_user_command("UpdateCreated", function()
    _G.update_frontmatter_date("created")
end, {})
