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
        -- created 语义上是"创建时定格"：仅当字段缺失时补写，不覆盖已有值
        if vim.bo.filetype ~= "markdown" then
            return
        end
        local md = require("util.markdown")
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local new_lines, changed = md.update_frontmatter_date(lines, "created", false)
        if changed then
            vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
            vim.cmd("write")
            require("util.notify").info("Added 'created' (existing value kept)")
        end
    end, { desc = "Set frontmatter 'created' if missing" })

    vim.api.nvim_buf_create_user_command(buf, "UpdateFrontMatter", function()
        M.update_frontmatter()
    end, { desc = "Create/normalize frontmatter from template" })
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

---新建/归一化当前笔记的 frontmatter（模板驱动）。
---没有 frontmatter → 新建；有 → 格式对则不动，格式不对则
---保持原 id/aliases/tags、更新 date、保留 created。
function M.update_frontmatter()
    if vim.bo.filetype ~= "markdown" then
        return
    end

    local ok, err = pcall(function()
        local Note = require("obsidian.note")
        local ofm = require("util.obsidian_frontmatter")
        local Frontmatter = require("obsidian.frontmatter")
        local buf = vim.api.nvim_get_current_buf()
        local note = Note.from_buffer(buf)

        if note.has_frontmatter and ofm.is_well_formed(note) then
            require("util.notify").info("Frontmatter already in correct format; no change")
            return
        end

        local target = ofm.command_frontmatter(note)
        local new_lines = Frontmatter.dump(target, ofm.sort)
        local count = note.has_frontmatter and (note.frontmatter_end_line or 0) or 0
        vim.api.nvim_buf_set_lines(buf, 0, count, false, new_lines)
        vim.cmd("write")
        local msg = note.has_frontmatter and "Frontmatter updated" or "Frontmatter created"
        require("util.notify").info(msg)
    end)
    if not ok then
        require("util.notify").error("UpdateFrontMatter: " .. tostring(err))
    end
end

return M
