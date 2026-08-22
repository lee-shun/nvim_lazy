-- Neovim configuration entry point
-- All setup logic is delegated to lua/config/init.lua for a LazyVim-like structure.

-- Minimum Neovim version: 0.11
-- (vim.lsp.config/vim.lsp.enable new API, vim.version(), inccommand, vim.hl.on_yank)
do
    local ok, v = pcall(vim.version)
    local ver_ok = ok and (v.major > 0 or v.minor >= 11)
    if not ver_ok then
        local cur = ok and string.format("%d.%d.%d", v.major, v.minor, v.patch) or "unknown"
        vim.fn.stderr("This config requires Neovim >= 0.11 (current: " .. cur .. ")\n")
        vim.fn.exit(1)
    end
end

require("config").setup()
