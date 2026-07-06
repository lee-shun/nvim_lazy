local M = {}

function M.exit_visual_and_get_range(callback)
    local mode = vim.fn.mode()
    if not (mode:match("[vV\22]")) then
        vim.notify("This function can only be used in visual mode", vim.log.levels.WARN)
        return
    end

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

    vim.defer_fn(function()
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local start_line, start_col = start_pos[2], start_pos[3]
        local end_line, end_col = end_pos[2], end_pos[3]

        if start_line > end_line or (start_line == end_line and start_col > end_col) then
            start_line, end_line = end_line, start_line
            start_col, end_col = end_col, start_col
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

        if #lines == 0 then
            return
        end

        callback(bufnr, start_line, end_line, lines)

        vim.fn.setpos("'<", { 0, 0, 0, 0 })
        vim.fn.setpos("'>", { 0, 0, 0, 0 })
        vim.api.nvim_win_set_cursor(0, { start_line, 0 })
    end, 10)
end

function M.visual_to_normal(callback)
    vim.cmd("normal! V")
    vim.defer_fn(function()
        callback()
    end, 10)
end

return M
