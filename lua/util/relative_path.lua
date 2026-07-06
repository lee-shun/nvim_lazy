-- relative_path.lua
local M = {}

--- Compute the relative path of target with respect to the directory of current.
--- Both current and target are absolute paths.
function M.relative_path(current, target)
    local current_dir = vim.fs.dirname(current)
    return vim.fs.relpath(current_dir, target) or "."
end

return M
