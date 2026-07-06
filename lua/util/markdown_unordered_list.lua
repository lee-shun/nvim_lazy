-- Toggle unordered list in visual mode
local visual = require("util.visual_selection")

local unordered_patterns = {
    "^%s*[-*+]%s+",
    "^%s*[•·●○■□▶]%s+",
    "^%s*[、]%s+",
}

local function is_unordered_line(line)
    for _, pattern in ipairs(unordered_patterns) do
        if line:match(pattern) then
            return true
        end
    end
    return false
end

local function remove_unordered_mark(line)
    local new_line = line
    for _ = 1, #unordered_patterns do
        new_line = new_line:gsub("^(%s*)[-*+•·●○■□▶、]%s+", "%1")
    end
    return new_line
end

local function get_list_mark()
    local ft = vim.bo.filetype
    if ft == "markdown" or ft == "org" then
        return "- "
    end
    return "• "
end

local function toggle_unordered_list()
    visual.exit_visual_and_get_range(function(bufnr, start_line, end_line, lines)
        local all_unordered = true
        for _, line in ipairs(lines) do
            if not is_unordered_line(line) then
                all_unordered = false
                break
            end
        end

        local new_lines = {}
        if all_unordered then
            for _, line in ipairs(lines) do
                table.insert(new_lines, remove_unordered_mark(line))
            end
        else
            for _, line in ipairs(lines) do
                if not is_unordered_line(line) then
                    local indent = line:match("^(%s*)")
                    local content = line:sub(#indent + 1)
                    table.insert(new_lines, indent .. get_list_mark() .. content)
                else
                    table.insert(new_lines, line)
                end
            end
        end

        vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, new_lines)
    end)
end

vim.keymap.set("v", "<leader>mu", toggle_unordered_list, {
    noremap = true,
    silent = true,
    desc = "Toggle unordered list",
})

vim.keymap.set("n", "<leader>mu", function()
    visual.visual_to_normal(toggle_unordered_list)
end, {
    noremap = true,
    silent = true,
    desc = "Toggle unordered list for current line",
})

-- Advanced: toggle with indent level support
local bullet_types = { "- ", "  - ", "    - ", "      - " }

local function toggle_unordered_list_with_indent()
    visual.exit_visual_and_get_range(function(bufnr, start_line, end_line, lines)
        local all_unordered = true
        for _, line in ipairs(lines) do
            if not is_unordered_line(line) then
                all_unordered = false
                break
            end
        end

        local new_lines = {}
        if all_unordered then
            for _, line in ipairs(lines) do
                table.insert(new_lines, line:gsub("^(%s*)[-*+•·●○■□▶、]%s+", "%1"))
            end
        else
            for _, line in ipairs(lines) do
                if not is_unordered_line(line) then
                    local indent = line:match("^(%s*)")
                    local indent_level = math.floor(#indent / 2) + 1
                    local bullet_type = bullet_types[math.min(indent_level, #bullet_types)]
                        or bullet_types[#bullet_types]
                    local content = line:sub(#indent + 1)
                    local new_indent = string.rep("  ", indent_level - 1)
                    table.insert(new_lines, new_indent .. bullet_type:gsub("^%s*", "") .. content)
                else
                    table.insert(new_lines, line)
                end
            end
        end

        vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, new_lines)
    end)
end

vim.keymap.set("v", "<leader>mU", toggle_unordered_list_with_indent, {
    noremap = true,
    silent = true,
    desc = "Toggle unordered list (with indent levels)",
})
