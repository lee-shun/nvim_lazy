-- Toggle ordered list in visual mode
local visual = require("util.visual_selection")

local list_pattern = "^%s*(%d+)[%.%)]%s+"
local chinese_pattern = "^%s*(%d+)[、.]%s+"

local function is_ordered_line(line)
    return line:match(list_pattern) or line:match(chinese_pattern)
end

local function remove_ordered_mark(line)
    local new_line = line:gsub("^(%s*)(%d+)[%.%)]%s+", "%1")
    if new_line == line then
        new_line = line:gsub("^(%s*)(%d+)[、.]%s+", "%1")
    end
    return new_line
end

local function toggle_ordered_list()
    visual.exit_visual_and_get_range(function(bufnr, start_line, end_line, lines)
        local all_ordered = true
        for _, line in ipairs(lines) do
            if not is_ordered_line(line) then
                all_ordered = false
                break
            end
        end

        local new_lines = {}
        if all_ordered then
            for _, line in ipairs(lines) do
                table.insert(new_lines, remove_ordered_mark(line))
            end
        else
            for i, line in ipairs(lines) do
                if not is_ordered_line(line) then
                    local indent = line:match("^(%s*)")
                    local content = line:sub(#indent + 1)
                    table.insert(new_lines, indent .. string.format("%d. ", i) .. content)
                else
                    table.insert(new_lines, line)
                end
            end
        end

        vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, new_lines)
    end)
end

vim.keymap.set("v", "<leader>mn", toggle_ordered_list, {
    noremap = true,
    silent = true,
    desc = "Toggle ordered list",
})

vim.keymap.set("n", "<leader>mn", function()
    visual.visual_to_normal(toggle_ordered_list)
end, {
    noremap = true,
    silent = true,
    desc = "Toggle ordered list for current line",
})
