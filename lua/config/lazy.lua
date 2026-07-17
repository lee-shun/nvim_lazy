-- lazy.nvim bootstrap and plugin spec loading
-- Kept separate from init.lua so the entry point stays minimal.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Clone lazy.nvim if it is not already installed
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

-- Make lazy.nvim available before requiring plugin specs
vim.opt.rtp:prepend(lazypath)

-- Import all plugin specs. Subdirectories are explicitly imported in plugins/init.lua.
require("lazy").setup("plugins")
