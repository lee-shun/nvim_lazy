-- Project root and project-type detection helpers.
-- Used by build/run plugins (overseer) and available to LSP/DAP configs.

local M = {}

---Find the nearest ancestor directory containing any of the given markers.
---@param markers string[]
---@param start_path? string default: current buffer directory
---@return string|nil
function M.find_root(markers, start_path)
    local dir = start_path or vim.fn.expand("%:p:h")
    while dir and dir ~= "/" do
        for _, marker in ipairs(markers) do
            local p = dir .. "/" .. marker
            if vim.fn.filereadable(p) == 1 or vim.fn.isdirectory(p) == 1 then
                return dir
            end
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            break
        end
        dir = parent
    end
    return nil
end

---Detect whether the current file is inside a ROS2 workspace.
---@param start_path? string
---@return boolean ok
---@return string|nil root
function M.is_ros2_workspace(start_path)
    local root = M.find_root({ "src", "build", "install", "log" }, start_path)
    if not root then
        return false, nil
    end

    local entries = vim.fn.readdir(root .. "/src")
    if type(entries) ~= "table" then
        return false, nil
    end

    for _, name in ipairs(entries) do
        if vim.fn.isdirectory(root .. "/src/" .. name) == 1 then
            if vim.fn.filereadable(root .. "/src/" .. name .. "/package.xml") == 1 then
                return true, root
            end
        end
    end
    return false, nil
end

---Detect whether the current file is inside a CMake project.
---Stops at the first directory that contains CMakeLists.txt.
---@param start_path? string
---@return boolean ok
---@return string|nil root
function M.is_cmake_project(start_path)
    local dir = start_path or vim.fn.expand("%:p:h")
    local root = nil
    while dir and dir ~= "/" do
        if vim.fn.filereadable(dir .. "/CMakeLists.txt") == 1 then
            root = dir
        elseif root then
            break
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            break
        end
        dir = parent
    end
    return root ~= nil, root
end

return M
