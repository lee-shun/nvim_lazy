local api = vim.api

-- go to last loc when opening a buffer
local recoverPos = api.nvim_create_augroup("RecoverPos", { clear = true })
api.nvim_create_autocmd("BufReadPost", {
    command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]],
    group = recoverPos,
})
-- Highlight on yank
local yankGrp = api.nvim_create_augroup("YankHighlight", { clear = true })
api.nvim_create_autocmd("TextYankPost", {
    command = "silent! lua vim.highlight.on_yank {timeout=300}",
    group = yankGrp,
})

-- format options
local formatOpt = api.nvim_create_augroup("FormatOpt", { clear = true })
api.nvim_create_autocmd("BufEnter", {
    command = "setlocal formatoptions+=m formatoptions+=B formatoptions-=o",
    group = formatOpt,
})

-- show cursor line only in active window
local cursorGrp = api.nvim_create_augroup("CursorLine", { clear = true })
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, { pattern = "*", command = "set cursorline", group = cursorGrp })
api.nvim_create_autocmd(
    { "InsertEnter", "WinLeave" },
    { pattern = "*", command = "set nocursorline", group = cursorGrp }
)

-- better file types
local betterFileType = api.nvim_create_augroup("BetterFileType", { clear = true })
api.nvim_create_autocmd(
    { "BufNewFile", "BufRead" },
    { pattern = "*.launch", command = "set filetype=xml", group = betterFileType }
)
api.nvim_create_autocmd(
    { "BufNewFile", "BufRead" },
    { pattern = "*.msg", command = "set filetype=rosmsg", group = betterFileType }
)
api.nvim_create_autocmd(
    { "BufNewFile", "BufRead" },
    { pattern = "*.srv", command = "set filetype=rosmsg", group = betterFileType }
)

-- number toggle
local numToggle = api.nvim_create_augroup("NumToggle", { clear = true })
api.nvim_create_autocmd(
    { "BufEnter", "FocusGained", "InsertLeave", "WinEnter" },
    { command = [[if &number | set relativenumber | endif]], group = numToggle }
)
api.nvim_create_autocmd(
    { "BufLeave", "FocusLost", "InsertEnter", "WinLeave" },
    { command = [[if &number | set norelativenumber | endif]], group = numToggle }
)

-- dynamic smart case
local dynamicSmartCase = api.nvim_create_augroup("DynamicSmartCase", { clear = true })
api.nvim_create_autocmd({ "CmdLineEnter" }, { command = "set nosmartcase", group = dynamicSmartCase })
api.nvim_create_autocmd({ "CmdLineLeave" }, { command = "set smartcase", group = dynamicSmartCase })
