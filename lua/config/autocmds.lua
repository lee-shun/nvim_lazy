-- Global autocommands and small helper functions.
-- Consolidates the old plugin/general.lua, plugin/timestamp.vim and plugin/searchcode.vim.

local api = vim.api

-- ─────────────────────────────────────────────────────────────
-- 1. Restore cursor position when reopening a buffer
-- ─────────────────────────────────────────────────────────────
local recover_pos = api.nvim_create_augroup("RecoverPos", { clear = true })
api.nvim_create_autocmd("BufReadPost", {
    group = recover_pos,
    desc = "Restore cursor to last known position",
    callback = function()
        local mark = api.nvim_buf_get_mark(0, '"')
        local lcount = api.nvim_buf_line_count(0)
        if mark[1] > 1 and mark[1] <= lcount then
            pcall(api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- ─────────────────────────────────────────────────────────────
-- 2. Highlight yanked text briefly
-- ─────────────────────────────────────────────────────────────
local yank_grp = api.nvim_create_augroup("YankHighlight", { clear = true })
api.nvim_create_autocmd("TextYankPost", {
    group = yank_grp,
    desc = "Highlight yanked region",
    callback = function()
        vim.hl.on_yank({ timeout = 300 })
    end,
})

-- ─────────────────────────────────────────────────────────────
-- 3. Tweak formatoptions for all buffers
-- ─────────────────────────────────────────────────────────────
local format_opt = api.nvim_create_augroup("FormatOpt", { clear = true })
api.nvim_create_autocmd("BufEnter", {
    group = format_opt,
    desc = "Disable automatic comment continuation on 'o'",
    callback = function()
        vim.opt_local.formatoptions:append("mB")
        vim.opt_local.formatoptions:remove("o")
    end,
})

-- ─────────────────────────────────────────────────────────────
-- 4. Show cursorline only in the active window
-- ─────────────────────────────────────────────────────────────
local cursor_grp = api.nvim_create_augroup("CursorLine", { clear = true })
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    group = cursor_grp,
    desc = "Enable cursorline in active window",
    callback = function()
        vim.wo.cursorline = true
    end,
})
api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
    group = cursor_grp,
    desc = "Disable cursorline in inactive window",
    callback = function()
        vim.wo.cursorline = false
    end,
})

-- ─────────────────────────────────────────────────────────────
-- 5. Better filetype detection
-- ─────────────────────────────────────────────────────────────
local better_ft = api.nvim_create_augroup("BetterFileType", { clear = true })
api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = better_ft,
    pattern = "*.launch",
    desc = "Treat .launch files as XML",
    command = "set filetype=xml",
})
api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = better_ft,
    pattern = { "*.msg", "*.srv" },
    desc = "Treat ROS message/service files as rosmsg",
    command = "set filetype=rosmsg",
})

-- ─────────────────────────────────────────────────────────────
-- 6. Relative number toggle based on mode/focus
-- ─────────────────────────────────────────────────────────────
local num_toggle = api.nvim_create_augroup("NumToggle", { clear = true })
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    group = num_toggle,
    desc = "Enable relative line numbers",
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = true
        end
    end,
})
api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    group = num_toggle,
    desc = "Disable relative line numbers",
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = false
        end
    end,
})

-- ─────────────────────────────────────────────────────────────
-- 7. Dynamic smartcase: disable smartcase while in command-line
-- ─────────────────────────────────────────────────────────────
local smartcase_grp = api.nvim_create_augroup("DynamicSmartCase", { clear = true })
api.nvim_create_autocmd("CmdLineEnter", {
    group = smartcase_grp,
    desc = "Disable smartcase in command-line",
    callback = function()
        vim.o.smartcase = false
    end,
})
api.nvim_create_autocmd("CmdLineLeave", {
    group = smartcase_grp,
    desc = "Re-enable smartcase after command-line",
    callback = function()
        vim.o.smartcase = true
    end,
})

-- ─────────────────────────────────────────────────────────────
-- 8. Timestamp auto-update on save
-- ─────────────────────────────────────────────────────────────

--- Update matching "Last [Cc]hange(d)? / [Mm]odified / [Uu]pdate(d)?" lines.
local function time_stamp()
    -- Double guard: the autocmd already filters by file extension, but bail
    -- out here as well if something calls TimeStamp() from a non-text buffer.
    local allowed = { markdown = true, org = true, text = true }
    if not allowed[vim.bo.filetype] then
        return
    end

    local time_str = os.date("%a %d %b %Y %I:%M:%S %p")

    -- Each pattern captures the prefix (e.g. "Last changed:") so we can preserve it.
    local patterns = {
        "^(%s*[Ll]ast%s+[Cc]hanged?%s*:)%s*.*$",
        "^(%s*[Cc]hanged?%s*:)%s*.*$",
        "^(%s*[Ll]ast%s+[Mm]odified%s*:)%s*.*$",
        "^(%s*[Mm]odified%s*:)%s*.*$",
        "^(%s*[Ll]ast%s+[Uu]pdated?%s*:)%s*.*$",
        "^(%s*[Uu]pdated?%s*:)%s*.*$",
    }

    local line_count = api.nvim_buf_line_count(0)
    for lineno = 1, line_count do
        local line = api.nvim_buf_get_lines(0, lineno - 1, lineno, false)[1]
        if line then
            for _, pat in ipairs(patterns) do
                local prefix = line:match(pat)
                if prefix then
                    local newline = prefix .. " " .. time_str
                    if newline ~= line then
                        api.nvim_buf_set_lines(0, lineno - 1, lineno, false, { newline })
                    end
                    break
                end
            end
        end
    end
end

api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.md", "*.org", "*.txt" },
    desc = "Auto-update timestamp before saving",
    callback = function()
        time_stamp()
    end,
})

-- ─────────────────────────────────────────────────────────────
-- 9. Visual selection search (previously plugin/searchcode.vim)
--    → 已移至 lua/config/keymaps.lua（它是键位，不是 autocmd）
-- ─────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────────────────────────
-- 10. DAP winbar (moved here because it is a global autocmd)
-- ─────────────────────────────────────────────────────────────
local dap_winbar = api.nvim_create_augroup("DapWinbar", { clear = true })
api.nvim_create_autocmd("FileType", {
    group = dap_winbar,
    pattern = "dap*",
    desc = "Show filename in DAP windows",
    command = "setlocal winbar=%f",
})
