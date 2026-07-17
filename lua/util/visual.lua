-- Visual-mode helpers.
-- All functions are safe to call from normal or visual modes.

local M = {}

---Return true if the editor is in any visual mode (char/line/block).
function M.is_visual()
    local mode = vim.fn.mode()
    return mode:match("^[vV\22]") ~= nil
end

---Get the visual selection start/end positions from the '< and '> marks.
---Both positions are 1-based line numbers and column numbers.
---@return table start_pos
---@return table end_pos
function M.get_visual_pos()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    return start_pos, end_pos
end

---Normalize a visual range so start <= end (both line and column).
---@param s_row integer
---@param s_col integer
---@param e_row integer
---@param e_col integer
function M.normalize_range(s_row, s_col, e_row, e_col)
    if s_row > e_row or (s_row == e_row and s_col > e_col) then
        return e_row, e_col, s_row, s_col
    end
    return s_row, s_col, e_row, e_col
end

---Execute a callback with the current visual selection.
---Exits visual mode first so '< and '> marks are updated, then calls:
---  callback(bufnr, start_line, end_line, lines)
---where start_line/end_line are 1-based and lines is a string array.
---@param callback fun(bufnr: integer, start_line: integer, end_line: integer, lines: string[])
function M.with_selection(callback)
    if not M.is_visual() then
        vim.notify("This function can only be used in visual mode", vim.log.levels.WARN)
        return
    end

    -- Exit visual mode to update '< and '> marks.
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "n",
        false
    )

    vim.defer_fn(function()
        local s_pos, e_pos = M.get_visual_pos()
        local s_row, s_col = s_pos[2], s_pos[3]
        local e_row, e_col = e_pos[2], e_pos[3]

        s_row, s_col, e_row, e_col = M.normalize_range(s_row, s_col, e_row, e_col)

        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, s_row - 1, e_row, false)

        if #lines == 0 then
            return
        end

        callback(bufnr, s_row, e_row, lines)

        -- Clear visual marks and restore cursor to selection start.
        vim.fn.setpos("'<", { 0, 0, 0, 0 })
        vim.fn.setpos("'>", { 0, 0, 0, 0 })
        vim.api.nvim_win_set_cursor(0, { s_row, 0 })
    end, 10)
end

---Select the current line in visual-line mode, then run callback.
---Used to reuse visual-line functions from normal mode.
---@param callback fun()
function M.from_normal_line(callback)
    vim.cmd("normal! V")
    vim.defer_fn(callback, 10)
end

return M
