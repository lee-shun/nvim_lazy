-- Generic text wrapping helpers for normal and visual modes.
-- Originally written for LaTeX bold/escape, but pattern-agnostic.

local M = {}

---Wrap the character under the cursor in normal mode.
---@param pattern string e.g. "\\boldsymbol"
local function wrap_normal(pattern)
    local row, col = require("util.buffer").cursor_pos()
    local line = vim.api.nvim_get_current_line()
    local char = string.sub(line, col + 1, col + 1)

    if char == "" then
        return
    end

    local wrapped = pattern .. "{" .. char .. "}"
    vim.api.nvim_buf_set_text(0, row, col, row, col + 1, { wrapped })
end

---Wrap each line independently in visual block mode.
---@param pattern string
---@param start_pos table
---@param end_pos table
local function wrap_block(pattern, start_pos, end_pos)
    local s_row, s_col = start_pos[2], start_pos[3]
    local e_row, e_col = end_pos[2], end_pos[3]

    if s_row > e_row then
        s_row, e_row = e_row, s_row
    end
    if s_col > e_col then
        s_col, e_col = e_col, s_col
    end

    for lnum = e_row, s_row, -1 do
        local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
        if not ok or #line == 0 then
            goto continue
        end
        line = line[1]

        local col_start = math.min(s_col, #line + 1)
        local col_end = math.min(e_col, #line)

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

---Wrap the whole selection as one unit in visual-line mode.
---@param pattern string
---@param start_line integer
---@param end_line integer
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

---Wrap the whole selection as one unit in visual-char mode.
---@param pattern string
---@param start_pos table
---@param end_pos table
local function wrap_char(pattern, start_pos, end_pos)
    local s_row, s_col = start_pos[2], start_pos[3]
    local e_row, e_col = end_pos[2], end_pos[3]

    if s_row > e_row or (s_row == e_row and s_col > e_col) then
        s_row, e_row = e_row, s_row
        s_col, e_col = e_col, s_col
    end

    local lines = {}
    for lnum = s_row, e_row do
        local ok, content = pcall(vim.api.nvim_buf_get_lines, 0, lnum - 1, lnum, false)
        local line_content = (ok and #content > 0) and content[1] or ""

        local line_start_col = (lnum == s_row) and math.min(s_col, #line_content + 1) or 1
        local line_end_col = (lnum == e_row) and math.min(e_col, #line_content) or #line_content

        if line_start_col <= line_end_col then
            table.insert(lines, string.sub(line_content, line_start_col, line_end_col))
        else
            table.insert(lines, "")
        end
    end

    local selected = table.concat(lines, "\n")
    local wrapped = pattern .. "{" .. selected .. "}"
    local wrapped_lines = vim.split(wrapped, "\n", { plain = true })

    vim.api.nvim_buf_set_text(0, s_row - 1, s_col - 1, e_row - 1, e_col, wrapped_lines)
end

---Wrap the current cursor/selection with a LaTeX-like pattern.
---Supports normal, visual-char, visual-line and visual-block modes.
---@param pattern string
function M.wrap_selection(pattern)
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

return M
