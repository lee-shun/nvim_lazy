-- Buffer and cursor utilities.
-- Pure helpers that do not depend on plugin state.

local M = {}

---Return the current cursor position as 0-based {row, col}.
function M.cursor_pos()
    local pos = vim.api.nvim_win_get_cursor(0)
    return pos[1] - 1, pos[2]
end

---Insert text at the current cursor position and move the cursor to the end.
---@param text string
function M.insert_text_at_cursor(text)
    local row, col = M.cursor_pos()
    vim.api.nvim_buf_set_text(0, row, col, row, col, { text })
    vim.api.nvim_win_set_cursor(0, { row + 1, col + #text })
end

---Get lines from the current buffer (0-based, end exclusive).
---@param start_row integer
---@param end_row integer
---@return string[]
function M.get_lines(start_row, end_row)
    return vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
end

---Set lines in the current buffer (0-based, end exclusive).
---@param start_row integer
---@param end_row integer
---@param lines string[]
function M.set_lines(start_row, end_row, lines)
    vim.api.nvim_buf_set_lines(0, start_row, end_row, false, lines)
end

---Get the current buffer number.
function M.bufnr()
    return vim.api.nvim_get_current_buf()
end

return M
