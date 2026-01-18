-- relative_path.lua
local M = {} -- Create a table to hold the module's exports

-- Function to compute the relative path of target with respect to the directory of current.
-- Both current and target are absolute paths.
function M.relative_path(current, target)
    -- Get the directory of the current file
    local current_dir = vim.fs.dirname(current)

    -- Split paths into components, handling leading '/' by including empty string at start
    local current_parts = vim.split(current_dir, '/', { plain = true })
    local target_parts = vim.split(target, '/', { plain = true })

    -- Find the length of the common prefix
    local i = 1
    while i <= #current_parts and i <= #target_parts and current_parts[i] == target_parts[i] do
        i = i + 1
    end
    local common = i - 1

    -- Number of '..' to go up from current_dir to the common prefix
    local ups = #current_parts - common

    -- Build the relative path
    local rel = {}
    for _ = 1, ups do
        table.insert(rel, '..')
    end

    if ups == 0 then
        table.insert(rel, '.')
    end

    for j = common + 1, #target_parts do
        table.insert(rel, target_parts[j])
    end

    -- Handle case where relative path is empty (same file, but unlikely since different paths)
    if #rel == 0 then
        return '.'
    end

    return table.concat(rel, '/')
end

return M -- Return the module table
