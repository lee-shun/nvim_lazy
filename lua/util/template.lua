-- Template scanning utilities used by Telescope and vim-templates integration.

local M = {}

local cache = nil

---Scan the nvim template directory for *.template files.
---Results are cached until clear_cache() is called.
---@return table[] items each item is { name, display_path, full_path }
function M.scan()
    if cache then
        return cache
    end

    local conf_dir = vim.fn.stdpath("config")
    local tmpl_dir = conf_dir .. "/template"
    local pattern = tmpl_dir .. "/**/*.template"

    cache = {}
    local template_files = vim.fn.glob(pattern, 1)
    if template_files == "" then
        return cache
    end

    template_files = vim.split(template_files, "\n")
    for _, full_path in ipairs(template_files) do
        if full_path ~= "" then
            local display_path = full_path:sub(#tmpl_dir + 2)
            local item = vim.fn.fnamemodify(full_path, ":t:r")
            table.insert(cache, {
                item,         -- name
                display_path, -- display
                full_path,    -- full path
            })
        end
    end

    return cache
end

---Clear the template scan cache. Call this after adding/removing templates.
function M.clear_cache()
    cache = nil
end

return M
