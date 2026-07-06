local api = vim.api

-- go to last loc when opening a buffer
local recoverPos = api.nvim_create_augroup("RecoverPos", { clear = true })
api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 1 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    group = recoverPos,
})

-- Highlight on yank
local yankGrp = api.nvim_create_augroup("YankHighlight", { clear = true })
api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ timeout = 300 })
    end,
    group = yankGrp,
})

-- format options
local formatOpt = api.nvim_create_augroup("FormatOpt", { clear = true })
api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.opt_local.formatoptions:append("mB")
        vim.opt_local.formatoptions:remove("o")
    end,
    group = formatOpt,
})

-- show cursor line only in active window
local cursorGrp = api.nvim_create_augroup("CursorLine", { clear = true })
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    callback = function()
        vim.wo.cursorline = true
    end,
    group = cursorGrp,
})
api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
    callback = function()
        vim.wo.cursorline = false
    end,
    group = cursorGrp,
})

-- better file types
local betterFileType = api.nvim_create_augroup("BetterFileType", { clear = true })
api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.launch",
    command = "set filetype=xml",
    group = betterFileType,
})
api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.msg", "*.srv" },
    command = "set filetype=rosmsg",
    group = betterFileType,
})

-- number toggle
local numToggle = api.nvim_create_augroup("NumToggle", { clear = true })
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = true
        end
    end,
    group = numToggle,
})
api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = false
        end
    end,
    group = numToggle,
})

-- dynamic smart case
local dynamicSmartCase = api.nvim_create_augroup("DynamicSmartCase", { clear = true })
api.nvim_create_autocmd("CmdLineEnter", {
    callback = function()
        vim.o.smartcase = false
    end,
    group = dynamicSmartCase,
})
api.nvim_create_autocmd("CmdLineLeave", {
    callback = function()
        vim.o.smartcase = true
    end,
    group = dynamicSmartCase,
})

-- auto-update timestamp on save
api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        vim.cmd("call TimeStamp()")
    end,
})
