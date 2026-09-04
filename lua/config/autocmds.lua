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

-- ─────────────────────────────────────────────────────────────
-- 11. Big file handling (replaces after/plugin/LargeFile.vim)
--     文件达到阈值（或平均行长过长，如 minified）时按大文件处理：
--     关 swap/backup/undo/syntax/folds/matchparen，并忽略 FileType
--     autocmd（跳过 ftplugin/语法/treesitter/ft 触发的懒加载插件）。
--     全局选项按窗口生效：切回普通 buffer 立即恢复，切回大文件再禁用。
--     :Unlarge 恢复本 buffer，:Large 强制启用
-- ─────────────────────────────────────────────────────────────
local bigfile = {
    size = 1.5 * 1024 * 1024, -- 1.5MB（LargeFile.vim 旧值 20MB）
    line_length = 1000, -- 平均行长超过此值也按大文件处理
    orig = nil, -- 全局选项快照（首个大文件打开时捕获）
    saved = {}, -- bufnr -> 选项快照
}

local bigfile_grp = api.nvim_create_augroup("BigFile", { clear = true })

--- 禁用全局选项（快照只捕获一次）
local function bigfile_set_globals_off()
    if not bigfile.orig then
        bigfile.orig = {
            ei = vim.o.ei,
            backup = vim.o.backup,
            writebackup = vim.o.writebackup,
            matchpairs = vim.o.matchpairs,
            matchtime = vim.o.matchtime,
        }
    end
    vim.o.ei = "FileType" -- 忽略 FileType：不加载 ftplugin/语法/treesitter
    vim.o.backup = false
    vim.o.writebackup = false
    vim.o.matchpairs = ""
    vim.o.matchtime = 0
end

--- 恢复全局选项（快照保留，切回大文件时重新禁用）
local function bigfile_set_globals_normal()
    local s = bigfile.orig
    if not s then
        return
    end
    vim.o.ei = s.ei
    vim.o.backup = s.backup
    vim.o.writebackup = s.writebackup
    vim.o.matchpairs = s.matchpairs
    vim.o.matchtime = s.matchtime
end

local function bigfile_disable(buf)
    if bigfile.saved[buf] then
        return
    end
    bigfile.saved[buf] = {
        swapfile = vim.bo[buf].swapfile,
        bufhidden = vim.bo[buf].bufhidden,
        undolevels = vim.bo[buf].undolevels,
        syntax = vim.bo[buf].syntax,
        foldmethod = vim.wo.foldmethod,
        foldenable = vim.wo.foldenable,
    }
    -- 本 buffer 局部选项
    vim.bo[buf].swapfile = false
    vim.bo[buf].bufhidden = "unload"
    vim.bo[buf].undolevels = -1
    vim.bo[buf].syntax = "none"
    -- 窗口局部选项（nvim 里 foldmethod/foldenable 是 w:local）
    vim.wo.foldmethod = "manual"
    vim.wo.foldenable = false
    bigfile_set_globals_off()
    vim.notify(
        ("大文件 `%s`：已禁用 swap/backup/undo/syntax/folds，:Unlarge 可恢复"):format(
            api.nvim_buf_get_name(buf)
        ),
        vim.log.levels.WARN
    )
end

local function bigfile_restore(buf)
    local s = bigfile.saved[buf]
    if not s then
        vim.notify("当前 buffer 未处于大文件模式", vim.log.levels.INFO)
        return
    end
    bigfile.saved[buf] = nil
    vim.bo[buf].swapfile = s.swapfile
    vim.bo[buf].bufhidden = s.bufhidden
    vim.bo[buf].undolevels = s.undolevels
    vim.bo[buf].syntax = s.syntax
    vim.wo.foldmethod = s.foldmethod
    vim.wo.foldenable = s.foldenable
    bigfile_set_globals_normal()
    if not next(bigfile.saved) then
        bigfile.orig = nil
    end
    vim.cmd("doautocmd FileType") -- 补跑被跳过的 ft 配置
    vim.notify("大文件处理已关闭", vim.log.levels.INFO)
end

api.nvim_create_autocmd("BufReadPre", {
    group = bigfile_grp,
    desc = "Big file: disable heavy features before loading",
    callback = function(args)
        if vim.fn.getfsize(args.file) >= bigfile.size then
            bigfile_disable(args.buf)
        end
    end,
})

api.nvim_create_autocmd("BufReadPost", {
    group = bigfile_grp,
    desc = "Big file: catch minified files with very long lines",
    callback = function(args)
        local buf = args.buf
        if bigfile.saved[buf] then
            return
        end
        local lines = api.nvim_buf_line_count(buf)
        if lines <= 0 then
            return
        end
        local size = vim.fn.line2byte(lines + 1)
        if size <= 0 then
            return
        end
        if size >= bigfile.size or (size - lines) / lines > bigfile.line_length then
            bigfile_disable(buf)
        end
    end,
})

api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = bigfile_grp,
    desc = "Big file: apply/restore globals per window",
    callback = function()
        local buf = api.nvim_get_current_buf()
        if bigfile.saved[buf] then
            vim.wo.foldmethod = "manual"
            vim.wo.foldenable = false
            bigfile_set_globals_off()
        else
            bigfile_set_globals_normal()
        end
    end,
})

api.nvim_create_autocmd("BufUnload", {
    group = bigfile_grp,
    desc = "Big file: clean up state on unload",
    callback = function(args)
        if bigfile.saved[args.buf] then
            bigfile.saved[args.buf] = nil
            if not next(bigfile.saved) then
                bigfile_set_globals_normal()
                bigfile.orig = nil
            end
        end
    end,
})

api.nvim_create_user_command("Large", function()
    bigfile_disable(api.nvim_get_current_buf())
end, { desc = "Force big-file handling on the current buffer" })
api.nvim_create_user_command("Unlarge", function()
    bigfile_restore(api.nvim_get_current_buf())
end, { desc = "Stop big-file handling on the current buffer" })
