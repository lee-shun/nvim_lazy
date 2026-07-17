-- Markdown utility functions.
-- All list/frontmatter helpers are pure: they receive lines and return new lines.

local M = {}

-- ─────────────────────────────────────────────────────────────
-- Timestamp / frontmatter helpers
-- ─────────────────────────────────────────────────────────────

---Insert a formatted timestamp at the current cursor position.
function M.insert_timestamp()
    local buf = require("util.buffer")
    local time_str = os.date("%Y-%m-%d  %H:%M:%S")
    buf.insert_text_at_cursor(time_str)
end

---Update a YAML frontmatter date field in the given lines.
---@param lines string[]
---@param field? string default "date"
---@return string[] new_lines
---@return boolean changed
function M.update_frontmatter_date(lines, field)
    field = field or "date"
    local escaped = field:gsub("[%-%.%+%[%]%(%)]", "%%%1")
    local pattern = "^" .. escaped .. "%s*:"

    local in_frontmatter = false
    local changed = false
    local new_time = os.date("%Y-%m-%d  %H:%M:%S")

    for i, line in ipairs(lines) do
        if line:match("^%-%-%-$") then
            if in_frontmatter then
                break
            else
                in_frontmatter = true
            end
        end

        if in_frontmatter and line:match(pattern) then
            lines[i] = field .. ": " .. new_time
            changed = true
        end
    end

    return lines, changed
end

-- ─────────────────────────────────────────────────────────────
-- Ordered list helpers
-- ─────────────────────────────────────────────────────────────

local ORDERED_PATTERNS = {
    "^%s*(%d+)[%.%)]%s+",
    "^%s*(%d+)[、.]%s+",
}

local function is_ordered_line(line)
    for _, p in ipairs(ORDERED_PATTERNS) do
        if line:match(p) then
            return true
        end
    end
    return false
end

local function remove_ordered_mark(line)
    local new_line = line:gsub("^(%s*)(%d+)[%.%)]%s+", "%1")
    if new_line == line then
        new_line = line:gsub("^(%s*)(%d+)[、.]%s+", "%1")
    end
    return new_line
end

---Toggle an ordered list for the given lines.
---@param lines string[]
---@return string[] new_lines
---@return boolean was_ordered
function M.toggle_ordered_list(lines)
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
    return new_lines, all_ordered
end

-- ─────────────────────────────────────────────────────────────
-- Unordered list helpers
-- ─────────────────────────────────────────────────────────────

local UNORDERED_MARKS = { "-", "*", "+", "•", "·", "●", "○", "■", "□", "▶", "、" }

local UNORDERED_PATTERNS = {
    "^%s*[-*+]%s+",
    "^%s*[•·●○■□▶]%s+",
    "^%s*[、]%s+",
}

local function is_unordered_line(line)
    for _, p in ipairs(UNORDERED_PATTERNS) do
        if line:match(p) then
            return true
        end
    end
    return false
end

local function remove_unordered_mark(line)
    return line:gsub("^(%s*)[-*+•·●○■□▶、]%s+", "%1")
end

local function default_bullet()
    local ft = vim.bo.filetype
    if ft == "markdown" or ft == "org" then
        return "- "
    end
    return "• "
end

---Toggle an unordered list for the given lines.
---@param lines string[]
---@param bullet? string override bullet text (default depends on filetype)
---@return string[] new_lines
---@return boolean was_unordered
function M.toggle_unordered_list(lines, bullet)
    bullet = bullet or default_bullet()

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
                table.insert(new_lines, indent .. bullet .. content)
            else
                table.insert(new_lines, line)
            end
        end
    end
    return new_lines, all_unordered
end

---Toggle an unordered list preserving 2-space indent levels.
---@param lines string[]
---@return string[] new_lines
---@return boolean was_unordered
function M.toggle_unordered_list_with_indent(lines)
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
                local indent_level = math.floor(#indent / 2) + 1
                local bullet = string.rep("  ", indent_level - 1) .. "- "
                local content = line:sub(#indent + 1)
                table.insert(new_lines, bullet .. content)
            else
                table.insert(new_lines, line)
            end
        end
    end
    return new_lines, all_unordered
end

return M
