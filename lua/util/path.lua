-- Path and filesystem helpers.

local M = {}

---Compute the relative path of `target` with respect to the directory of `current`.
---Both arguments must be absolute paths.
---@param current string
---@param target string
---@return string
function M.relative(current, target)
    local current_dir = vim.fs.dirname(current)
    return vim.fs.relpath(current_dir, target) or "."
end

---Return the Neovim configuration directory.
---@return string
function M.config()
    return vim.fn.stdpath("config")
end

---Join path components with '/'.
---@vararg string
---@return string
function M.join(...)
    return table.concat({ ... }, "/")
end

---Return the directory containing the current buffer file.
---@return string
function M.current_dir()
    return vim.fn.expand("%:p:h")
end

---Return the absolute path of the current buffer file.
---@return string
function M.current_file()
    return vim.fn.expand("%:p")
end

return M
