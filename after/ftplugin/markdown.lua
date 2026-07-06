vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.spell = true

local buf = vim.api.nvim_get_current_buf()

require("which-key").add({
    {
        "<leader>mr",
        function()
            vim.cmd("MarkdownPreview")
        end,
        buffer = buf,
        desc = "Preview",
    },
})

-- Insert formatted time at cursor
local function insert_formatted_time()
    local time_str = os.date("%Y-%m-%d  %H:%M:%S")
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local row = cursor_pos[1] - 1
    local col = cursor_pos[2]

    vim.api.nvim_buf_set_text(0, row, col, row, col, { time_str })
    vim.api.nvim_win_set_cursor(0, { cursor_pos[1], col + #time_str })
end

vim.keymap.set("i", "<C-t>", function()
    insert_formatted_time()
end, { noremap = true, silent = true, buffer = buf })

require("which-key").add({
    {
        "<C-t>",
        function()
            insert_formatted_time()
        end,
        buffer = buf,
        desc = "Insert formatted time",
        mode = "i",
    },
})

-- Update frontmatter date field
local function update_frontmatter_date(pattern)
    if vim.bo.filetype ~= "markdown" then
        return
    end

    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local in_frontmatter = false
    local date_updated = false

    pattern = pattern or "date"
    local escaped_pattern = pattern:gsub("[%-%.%+%[%]%(%)]", "%%%1")

    for i, line in ipairs(buf_lines) do
        if line:match("^%-%-%-$") then
            if in_frontmatter then
                break
            else
                in_frontmatter = true
            end
        end

        if in_frontmatter and line:match("^" .. escaped_pattern .. "%s*:") then
            local new_time = os.date("%Y-%m-%d  %H:%M:%S")
            buf_lines[i] = pattern .. ": " .. new_time
            date_updated = true
        end
    end

    if date_updated then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, buf_lines)
        vim.cmd("write")
        vim.notify("Updated '" .. pattern .. "' to current time", vim.log.levels.INFO)
    end
end

vim.api.nvim_create_user_command("UpdateDate", function()
    update_frontmatter_date()
end, {})

vim.api.nvim_create_user_command("UpdateCreated", function()
    update_frontmatter_date("created")
end, {})

-- Toggle ordered / unordered lists
require("util.markdown_ordered_list")
require("util.markdown_unordered_list")
