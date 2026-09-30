-- Template-driven frontmatter generator for obsidian.nvim.
--
-- 目标：让「保存时自动写入的 frontmatter」跟随模板文件变化。
-- 字段集合、字段顺序、占位符值都由 vault 的默认模板（templates.folder 下第一个 .md）
-- 决定；模板改了（按 mtime 自动失效缓存）下次保存即同步。
--
-- 语义：
--   * id / aliases / tags 用笔记的实时值（note.id / note.aliases / note.tags），
--     不用模板里的占位或空默认。
--   * 含 {{...}} 的字段用 obsidian 的模板 substitution 展开（复用 date/time/id/title 等）。
--   * 其它字段：笔记里已有值则保留（set-once，如 date/created/source），否则用模板值。
--   * 模板里没有、但笔记已存在的字段一律保留，不丢。

local M = {}

-- 模板缓存：同一路径同 mtime 直接复用；模板被编辑后 mtime 变 → 重新读取。
local cache = { path = nil, mtime = nil, fields = nil, pos = nil }

---读取模板文件的 frontmatter，返回有序的 { key, raw } 列表（raw 保留 {{占位符}}）。
---无模板目录/文件时返回 {}。
---@return { key: string, raw: string }[]
function M.fields()
    local api = require("obsidian.api")
    local dir = api.templates_dir()
    if dir == nil then
        return {}
    end
    local dir_str = tostring(dir)
    local files = {}
    for f in vim.fs.dir(dir_str) do
        if vim.endswith(f, ".md") then
            files[#files + 1] = f
        end
    end
    if #files == 0 then
        return {}
    end
    table.sort(files) -- 多个模板时取按名排序第一个（当前 vault 只有一个）
    local path = dir_str .. (vim.endswith(dir_str, "/") and "" or "/") .. files[1]

    local ok_mtime, mtime = pcall(vim.fn.getftime, path)
    if not ok_mtime or mtime < 0 then
        return {}
    end
    if cache.path == path and cache.mtime == mtime then
        return cache.fields
    end

    local fields = {}
    local in_fm = false
    for _, line in ipairs(vim.fn.readfile(path)) do
        if line:match("^%-%-%-%s*$") then
            if in_fm then
                break
            end
            in_fm = true
        elseif in_fm then
            local key, raw = line:match("^%s*([A-Za-z_][%w_%-]*)%s*:%s*(.*)$")
            if key then
                fields[#fields + 1] = { key = key, raw = raw or "" }
            end
        end
    end

    local pos = {}
    for i, f in ipairs(fields) do
        pos[f.key] = i
    end
    cache = { path = path, mtime = mtime, fields = fields, pos = pos }
    return fields
end

---某 key 在模板中的 1-based 位置；模板里没有则返回 math.huge（排到最后）。
---@param key string
---@return integer
function M.pos(key)
    M.fields()
    if cache.pos then
        return cache.pos[key] or math.huge
    end
    return math.huge
end

---给 frontmatter.sort 用的比较器：按模板里的字段顺序排。
---@param a string
---@param b string
---@return boolean
function M.sort(a, b)
    local pa, pb = M.pos(a), M.pos(b)
    if pa == pb then
        return tostring(a) < tostring(b)
    end
    return pa < pb
end

---把字面量 YAML 值解析成 Lua 值；解析失败则原样当字符串。
---@param s string
---@return any
local function yaml_value(s)
    local yaml = require("obsidian.yaml")
    local ok, res = pcall(yaml.loads, s)
    if ok and res ~= nil then
        return res
    end
    return s
end

---obsidian.nvim 的 frontmatter.func：由模板驱动地构建某笔记的 frontmatter 表。
---@param note obsidian.Note
---@return table<string, any>
function M.func(note)
    local templates = require("obsidian.templates")
    local ctx = { partial_note = note }
    local aliases = note.aliases or {}
    local tags = note.tags or {}
    local meta = note.metadata or {}

    local out = {}
    local seen = {}
    for _, f in ipairs(M.fields()) do
        local key, raw = f.key, f.raw
        seen[key] = true

        local val
        if raw:find("{{", 1, true) then
            val = templates.substitute_template_variables(raw, ctx)
        else
            val = yaml_value(raw)
        end

        -- 实时字段：用笔记当前值，而不是模板里的占位/空默认
        if key == "id" then
            val = tostring(note.id)
        elseif key == "aliases" and #aliases > 0 then
            val = aliases
        elseif key == "tags" and #tags > 0 then
            val = tags
        end

        -- 其余字段：已有值不覆盖（set-once）
        if key ~= "id" and key ~= "aliases" and key ~= "tags" and meta[key] ~= nil then
            val = meta[key]
        end

        out[key] = val
    end

    -- 保留模板里没有、但笔记已存在的其它字段
    for k, v in pairs(meta) do
        if not seen[k] and k ~= "id" and k ~= "aliases" and k ~= "tags" then
            out[k] = v
        end
    end

    return out
end

-- ─────────────────────────────────────────────────────────────
-- :UpdateFrontMatter 专用（手动命令）
-- 规则（用户指定）：
--   * 没有 frontmatter → 新建（按模板）。
--   * 有 frontmatter → 先查格式：格式对则不动；格式不对则
--       保持原 id/aliases/tags（note.* 即原值）、更新 date（现在）、保留 created。
-- ─────────────────────────────────────────────────────────────

---strftime 格式 → 数字匹配 pattern（%Y→4 位，%m/%d/%H/%M/%S→2 位，字面 - 转义为 %-）。
---注意：Lua pattern 里紧跟 atom 的 - 是"0 个或多个"量词，字面连字符必须写成 %-。
local function fmt_to_pattern(fmt)
    local out = {}
    local i = 1
    while i <= #fmt do
        local ch = fmt:sub(i, i)
        if ch == "%" then
            local spec = fmt:sub(i + 1, i + 1)
            if spec == "Y" then
                out[#out + 1] = "%d%d%d%d"
                i = i + 2
            elseif spec == "m" or spec == "d" or spec == "H" or spec == "M" or spec == "S" then
                out[#out + 1] = "%d%d"
                i = i + 2
            else
                out[#out + 1] = ch
                i = i + 1
            end
        elseif ch == "-" then
            out[#out + 1] = "%-"
            i = i + 1
        else
            out[#out + 1] = ch -- 数字/字母/空格/冒号等直接保留
            i = i + 1
        end
    end
    return table.concat(out)
end

---从模板的 date 字段推导日期值的匹配 pattern（保留模板里的空格）。
---@return string|nil
function M._date_pattern()
    local date_raw
    for _, f in ipairs(M.fields()) do
        if f.key == "date" then
            date_raw = f.raw
            break
        end
    end
    if date_raw == nil then
        return nil
    end
    local opts = Obsidian.opts.templates
    local date_format = (opts and opts.date_format) or "%Y-%m-%d"
    local time_format = (opts and opts.time_format) or "%H:%M:%S"
    -- 用函数替换，避免 pattern 里的 % 被当成 gsub 替换转义
    local pat = date_raw
        :gsub("{{date}}", function() return fmt_to_pattern(date_format) end)
        :gsub("{{time}}", function() return fmt_to_pattern(time_format) end)
    return "^" .. pat .. "$"
end

---:UpdateFrontMatter 要写出的 frontmatter 表（date=现在、created 保留或现在）。
---@param note obsidian.Note
---@return table<string, any>
function M.command_frontmatter(note)
    local templates = require("obsidian.templates")
    local ctx = { partial_note = note }
    local aliases = note.aliases or {}
    local tags = note.tags or {}
    local meta = note.metadata or {}

    local out = {}
    local seen = {}
    for _, f in ipairs(M.fields()) do
        local key = f.key
        seen[key] = true
        if key == "id" then
            out.id = tostring(note.id) -- 保持原 id（note.id 即前置里的原值）
        elseif key == "aliases" then
            out.aliases = #aliases > 0 and aliases or {}
        elseif key == "tags" then
            out.tags = #tags > 0 and tags or {}
        elseif key == "created" then
            out.created = meta.created or templates.substitute_template_variables(f.raw, ctx) -- 保留 created
        else
            if f.raw:find("{{", 1, true) then
                out[key] = templates.substitute_template_variables(f.raw, ctx) -- date→现在
            elseif meta[key] ~= nil then
                out[key] = meta[key]
            else
                out[key] = yaml_value(f.raw)
            end
        end
    end
    for k, v in pairs(meta) do
        if not seen[k] and k ~= "id" and k ~= "aliases" and k ~= "tags" then
            out[k] = v
        end
    end
    return out
end

---判断现有 frontmatter 是否已是模板正确格式（幂等门禁）。
---正确 = 模板所有字段都在、模板字段按模板顺序、且 date 值符合模板日期格式。
---@param note obsidian.Note
---@return boolean
function M.is_well_formed(note)
    if not note.has_frontmatter then
        return false
    end
    local fields = M.fields()
    if #fields == 0 then
        return true
    end

    local buf = note.bufnr or vim.api.nvim_get_current_buf()
    local end_line = note.frontmatter_end_line or 0
    local lines = vim.api.nvim_buf_get_lines(buf, 0, end_line, false)
    local ordered_keys = {}
    for _, line in ipairs(lines) do
        local key = line:match("^%s*([A-Za-z_][%w_%-]*)%s*:")
        if key then
            ordered_keys[#ordered_keys + 1] = key
        end
    end

    local template_keys = {}
    for _, f in ipairs(fields) do
        template_keys[#template_keys + 1] = f.key
    end

    -- (a) 模板字段都在
    local present = {}
    for _, k in ipairs(ordered_keys) do
        present[k] = true
    end
    for _, k in ipairs(template_keys) do
        if not present[k] then
            return false
        end
    end

    -- (b) 模板字段按模板顺序（模板字段子序列 == 模板顺序）
    local tset = {}
    for _, k in ipairs(template_keys) do
        tset[k] = true
    end
    local subseq = {}
    for _, k in ipairs(ordered_keys) do
        if tset[k] then
            subseq[#subseq + 1] = k
        end
    end
    if not vim.deep_equal(subseq, template_keys) then
        return false
    end

    -- (c) date 值符合模板日期格式（仅当模板含 date）
    for _, k in ipairs(template_keys) do
        if k == "date" then
            local d = (note.metadata or {})["date"]
            local pat = M._date_pattern()
            if pat == nil then
                return true -- 无法判定格式，放行
            end
            if type(d) ~= "string" or not d:match(pat) then
                return false
            end
            break
        end
    end
    return true
end

return M
