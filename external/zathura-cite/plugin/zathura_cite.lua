-- zathura-cite: zathura <-> nvim 双向 PDF 引用
-- 正向: zathura 选中按 Y -> drop 文件 -> 本插件在光标处插入 wikilink 引用
-- 反向: 光标停在引用行按 <CR> -> zathura 跳页（其余 CR 行为委托 obsidian.nvim）
local plugin_dir = vim.fs.abspath(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1).source:sub(2))))
vim.opt.rtp:prepend(plugin_dir)
local core = require("zathura_cite.core")

local M = {}
local DROP_DIR = "/tmp/zathura-cite"
local vault = vim.fn.expand("~/knowledge_library")
local enabled = vim.fn.isdirectory(vault) == 1

---------------- zathurarc ----------------

local function map_line(script_path)
  return "map Y exec " .. script_path .. "\\ $PAGE"
end

--- 幂等追加 map Y 行。已存在 -> false；写入 -> true
function M.install_zathurarc(zathurarc_path, script_path)
  local want = map_line(script_path)
  local f = io.open(zathurarc_path, "r")
  local existing = f and f:read("*a") or nil
  if f then f:close() end
  if existing and existing:find(want, 1, true) then return false end
  local out = io.open(zathurarc_path, "a")
  if not out then return false end
  if existing and existing:sub(-1) ~= "\n" then out:write("\n") end
  out:write(want .. "\n")
  out:close()
  return true
end

---------------- 正向: 消费 drop ----------------

function M.consume(drop_dir, insert_fn, notify)
  local p = core.latest_drop(drop_dir or DROP_DIR)
  if not p then return false end
  local d = core.parse_drop_file(p)
  vim.uv.fs_unlink(p)
  notify = notify or vim.notify
  if not d then
    notify("zathura-cite: drop 文件格式错误", vim.log.levels.WARN)
    return false
  end
  if d.text == "" then
    notify("zathura-cite: 无选中文字", vim.log.levels.WARN)
    return false
  end
  insert_fn(core.format_citation(d.page, d.file, core.clean_text(d.text), vault))
  return true
end

local function insert_citation(text)
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local l = (vim.api.nvim_buf_get_lines(buf, row - 1, row, true)[1]) or ""
  local first
  if col > #l then
    first = l .. text
    vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { first })
  else
    first = l:sub(1, col - 1) .. text
    vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { first, l:sub(col) })
  end
  vim.api.nvim_win_set_cursor(0, { row, #first + 1 })
end

---------------- 反向: 跳页 ----------------

function M.jump(m)
  local base = m.file:match("([^/]+)$")
  local out = (vim.fn.system({ "xdotool", "search", "--name", base }) or ""):gsub("%s+$", "")
  local wid = out:match("^[^%s]+")
  if wid then
    vim.fn.system({ "xdotool", "windowactivate", "--sync", wid })
    vim.fn.system({ "xdotool", "key", "--window", wid, tostring(m.page), "G" })
  else
    vim.fn.jobstart({ "zathura", "-P", tostring(m.page), m.file })
  end
end

---------------- <CR> dispatcher ----------------

local function dispatcher()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = (vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]) or ""
  local m = core.match_citation_line(line, vault)
  if m then
    M.jump(m)
    return "0"
  end
  local ok, actions = pcall(require, "obsidian.actions")
  if ok and actions.smart_action then return actions.smart_action() end
  return "<CR>"
end

M.dispatcher = dispatcher

local function set_cr_dispatcher()
  vim.keymap.set("n", "<CR>", dispatcher, {
    expr = true, buffer = true, desc = "zathura-cite jump / obsidian smart action",
  })
end

---------------- 装配 ----------------

if enabled then
  local zathura_cfg = vim.fn.expand("~/.config/zathura")
  if vim.fn.isdirectory(zathura_cfg) == 1
    and M.install_zathurarc(zathura_cfg .. "/zathurarc", plugin_dir .. "/bin/zath-cite.sh") then
    vim.notify("zathura-cite: zathurarc 已追加 map Y", vim.log.levels.INFO)
  end

  local ag = vim.api.nvim_create_augroup("zathura_cite", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = ag, pattern = "ObsidianNoteEnter", callback = set_cr_dispatcher,
  })
  vim.api.nvim_create_autocmd("FileType", {
    group = ag, pattern = "markdown",
    callback = function(ev)
      local f = vim.api.nvim_buf_get_name(ev.buf)
      if f:find(vault, 1, true) then set_cr_dispatcher() end
    end,
  })

  local timer = vim.uv.new_timer()
  timer:start(500, 500, vim.schedule_wrap(function()
    local buf = vim.api.nvim_get_current_buf()
    local f = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].filetype ~= "markdown" or not f:find(vault, 1, true) then return end
    if not vim.uv.fs_stat(DROP_DIR) or #vim.fn.readdir(DROP_DIR) == 0 then return end
    M.consume(DROP_DIR, insert_citation)
  end))

  vim.api.nvim_create_user_command("ZathuraCiteLatest", function()
    if M.consume(DROP_DIR, insert_citation) then vim.notify("zathura-cite: 已插入引用") end
  end, {})
  vim.api.nvim_create_user_command("ZathuraCiteJump", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = (vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]) or ""
    local m = core.match_citation_line(line, vault)
    if m then M.jump(m) else vim.notify("zathura-cite: 光标下无引用", vim.log.levels.WARN) end
  end, {})
end

return M
