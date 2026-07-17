-- Filetype-specific configuration dispatcher.
-- Each language module exposes a setup(buf) function that configures
-- buffer-local options, keymaps and commands.

local M = {}

-- Map filetype -> module name under lua/lang/
local dispatch = {
    markdown = "lang.markdown",
    tex = "lang.tex",
    plaintex = "lang.tex",
    c = "lang.cpp",
    cpp = "lang.cpp",
    python = "lang.python",
    typst = "lang.typst",
}

function M.setup()
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("LangDispatch", { clear = true }),
        desc = "Dispatch filetype setup to lua/lang modules",
        callback = function(args)
            local modname = dispatch[args.match]
            if modname then
                local ok, mod = pcall(require, modname)
                if ok and mod.setup then
                    mod.setup(args.buf)
                end
            end
        end,
    })
end

return M
