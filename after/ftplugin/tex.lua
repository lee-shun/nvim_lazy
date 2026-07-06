vim.opt_local.textwidth = 80
vim.opt_local.spell = true

local buf = vim.api.nvim_get_current_buf()

require("which-key").add({
    {
        "<leader>rt",
        function()
            vim.cmd("VimtexStop")
            vim.cmd("VimtexCompile")
        end,
        buffer = buf,
        desc = "Recompile",
    },
    {
        "<leader>rv",
        function()
            vim.cmd("VimtexView")
        end,
        buffer = buf,
        desc = "View the pdf",
    },
})

-- Normal mode: wrap character under cursor
local function wrap_normal(pattern)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor_pos[1], cursor_pos[2]
    local line = vim.api.nvim_get_current_line()
    local char = string.sub(line, col + 1, col + 1)

    if char == "" then
        return
    end

    local wrapped = pattern .. "{" .. char .. "}"
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col + 1, { wrapped })
end

-- Visual block mode: wrap each line independently
local function wrap_block(pattern, start_pos, end_pos)
    local start_line, start_col = start_pos[2], start_pos[3]
    local end_line, end_col = end_pos[2], end_pos[3]

    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    if start_col > end_col then
        start_col, end_col = end_col, start_col
    end

    for lnum = end_line, start_line, -1 do
        local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
        if not ok or #line == 0 then
            vim.api.nvim_buf_set_text(0, lnum - 1, start_col - 1, lnum - 1, start_col - 1, { pattern .. "{}" })
            goto continue
        end
        line = line[1]

        local col_start = math.min(start_col, #line + 1)
        local col_end = math.min(end_col, #line)

        if col_start <= col_end then
            local selected = string.sub(line, col_start, col_end)
            local wrapped = pattern .. "{" .. selected .. "}"
            vim.api.nvim_buf_set_text(0, lnum - 1, col_start - 1, lnum - 1, col_end, { wrapped })
        else
            vim.api.nvim_buf_set_text(0, lnum - 1, col_start - 1, lnum - 1, col_start - 1, { pattern .. "{}" })
        end
        ::continue::
    end
end

-- Visual line mode: wrap whole selection as one
local function wrap_line(pattern, start_line, end_line)
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    local lines = {}
    for lnum = start_line, end_line do
        local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
        if ok and #line > 0 then
            table.insert(lines, line[1])
        else
            table.insert(lines, "")
        end
    end

    local selected = table.concat(lines, "\n")
    local wrapped = pattern .. "{" .. selected .. "}"
    local wrapped_lines = vim.split(wrapped, "\n", { plain = true })

    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, wrapped_lines)
end

-- Visual char mode: wrap whole selection as one
local function wrap_char(pattern, start_pos, end_pos)
    local start_line, start_col = start_pos[2], start_pos[3]
    local end_line, end_col = end_pos[2], end_pos[3]

    if start_line > end_line or (start_line == end_line and start_col > end_col) then
        start_line, end_line = end_line, start_line
        start_col, end_col = end_col, start_col
    end

    local lines = {}
    for lnum = start_line, end_line do
        local ok, line_content = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
        if ok and #line_content > 0 then
            line_content = line_content[1]
        else
            line_content = ""
        end

        local line_start_col = (lnum == start_line) and math.min(start_col, #line_content + 1) or 1
        local line_end_col = (lnum == end_line) and math.min(end_col, #line_content) or #line_content

        if line_start_col <= line_end_col then
            table.insert(lines, string.sub(line_content, line_start_col, line_end_col))
        else
            table.insert(lines, "")
        end
    end

    local selected = table.concat(lines, "\n")
    local wrapped = pattern .. "{" .. selected .. "}"
    local wrapped_lines = vim.split(wrapped, "\n", { plain = true })

    vim.api.nvim_buf_set_text(0, start_line - 1, start_col - 1, end_line - 1, end_col, wrapped_lines)
end

local function wrap_with_pattern(pattern)
    local mode = vim.fn.mode()

    if mode == "n" then
        wrap_normal(pattern)
        return
    end

    local is_visual = mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode == "\22"
    if not is_visual then
        return
    end

    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")

    if mode == "\22" then
        wrap_block(pattern, start_pos, end_pos)
    elseif mode == "V" then
        wrap_line(pattern, start_pos[2], end_pos[2])
    else
        wrap_char(pattern, start_pos, end_pos)
    end
end

local function bold_and_escape()
    wrap_with_pattern("\\boldsymbol")
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "n",
        false
    )
end

require("which-key").add({
    {
        "<leader>bd",
        bold_and_escape,
        buffer = buf,
        desc = "Bold",
        mode = { "n", "v" },
    },
})
