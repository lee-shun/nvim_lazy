-- Markdown filetype configuration.
-- Moved from after/ftplugin/markdown.lua to keep business logic centralized.

local M = {}

function M.setup(buf)
    -- Buffer-local formatting options
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.spell = true

    local wk = require("which-key")
    local md = require("util.markdown")
    local visual = require("util.visual")

    -- ─────────────────────────────────────────────────────────
    -- Keymaps
    -- ─────────────────────────────────────────────────────────
    wk.add({
        { "<leader>mr", "<cmd>MarkdownPreview<cr>", buffer = buf, desc = "👁️ Preview" },
        {
            "<C-t>",
            function()
                md.insert_timestamp()
            end,
            buffer = buf,
            mode = "i",
            desc = "🕐 Insert timestamp",
        },
        {
            "<leader>mn",
            function()
                M.toggle_ordered()
            end,
            buffer = buf,
            desc = "🔢 Toggle ordered list",
        },
        {
            "<leader>mu",
            function()
                M.toggle_unordered()
            end,
            buffer = buf,
            desc = "📌 Toggle unordered list",
        },
        {
            "<leader>mU",
            function()
                M.toggle_unordered_indent()
            end,
            buffer = buf,
            desc = "📌 Toggle unordered (indent)",
        },
    })

    -- ─────────────────────────────────────────────────────────
    -- User commands
    -- ─────────────────────────────────────────────────────────
    vim.api.nvim_buf_create_user_command(buf, "UpdateDate", function()
        M.update_date("date")
    end, { desc = "Update frontmatter 'date' field" })

    vim.api.nvim_buf_create_user_command(buf, "UpdateCreated", function()
        M.update_date("created")
    end, { desc = "Update frontmatter 'created' field" })
end

---Toggle ordered list for the current visual selection.
function M.toggle_ordered()
    local visual = require("util.visual")
    visual.with_selection(function(_, s_row, e_row, lines)
        local new_lines, _ = require("util.markdown").toggle_ordered_list(lines)
        vim.api.nvim_buf_set_lines(0, s_row - 1, e_row, false, new_lines)
    end)
end

---Toggle unordered list for the current visual selection.
function M.toggle_unordered()
    local visual = require("util.visual")
    visual.with_selection(function(_, s_row, e_row, lines)
        local new_lines, _ = require("util.markdown").toggle_unordered_list(lines)
        vim.api.nvim_buf_set_lines(0, s_row - 1, e_row, false, new_lines)
    end)
end

---Toggle unordered list with indent-level awareness.
function M.toggle_unordered_indent()
    local visual = require("util.visual")
    visual.with_selection(function(_, s_row, e_row, lines)
        local new_lines, _ = require("util.markdown").toggle_unordered_list_with_indent(lines)
        vim.api.nvim_buf_set_lines(0, s_row - 1, e_row, false, new_lines)
    end)
end

---Update a frontmatter date field and save if changed.
---@param field string
function M.update_date(field)
    if vim.bo.filetype ~= "markdown" then
        return
    end

    local md = require("util.markdown")
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local new_lines, changed = md.update_frontmatter_date(lines, field)

    if changed then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
        vim.cmd("write")
        require("util.notify").info("Updated '" .. field .. "' to current time")
    end
end

return M
