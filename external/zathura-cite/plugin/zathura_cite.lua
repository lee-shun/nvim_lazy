-- zathura-cite: zathura <-> nvim 双向 PDF 引用
-- 正向: zathura 选中按 Y -> bin/zath-cite.sh 直接 nvim --remote-expr 在光标处插入引用（无中间文件）
-- 反向: 光标停在引用行按 <CR> -> zathura 跳页（其余 CR 行为委托 obsidian.nvim）
-- realpath 归一化：无论从 site symlink 还是 repo 直接加载，plugin_dir 都解析到同一真实路径
-- （否则 zathurarc 里的 script 路径会随加载方式来回翻转）
local _base = vim.fs.abspath(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1).source:sub(2))))
local plugin_dir = vim.uv.fs_realpath(_base, nil) or _base
vim.opt.rtp:prepend(plugin_dir)
local core = require("zathura_cite.core")

local M = {}
local vault = vim.fn.expand("~/knowledge_library")
local enabled = vim.fn.isdirectory(vault) == 1

---------------- zathurarc ----------------

local function map_line(script_path)
  return "map Y exec " .. script_path .. "\\ $PAGE"
end

--- 幂等维护 map Y 行：移除所有旧 zath-cite map 行后追加当前行
--- （script 路径变化时——如插件目录 symlink 解析变化——自动替换旧行）
function M.install_zathurarc(zathurarc_path, script_path)
  local want = map_line(script_path)
  local f = io.open(zathurarc_path, "r")
  local existing = f and f:read("*a") or nil
  if f then f:close() end
  local lines = {}
  if existing and existing ~= "" then
    lines = vim.split(existing, "\n", { plain = true })
    if lines[#lines] == "" then table.remove(lines) end
  end
  local kept = {}
  local had_stale = false
  local want_present = false
  for _, body in ipairs(lines) do
    if body == want then
      want_present = true
    elseif body:find("map Y exec ", 1, true) == 1 and body:find("zath-cite.sh", 1, true) then
      had_stale = true
    else
      kept[#kept + 1] = body
    end
  end
  if want_present and not had_stale then return false end
  local out = io.open(zathurarc_path, "w")
  if not out then return false end
  for _, body in ipairs(kept) do out:write(body .. "\n") end
  out:write(want .. "\n")
  out:close()
  return true
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

  vim.api.nvim_create_user_command("ZathuraCiteJump", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = (vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]) or ""
    local m = core.match_citation_line(line, vault)
    if m then M.jump(m) else vim.notify("zathura-cite: 光标下无引用", vim.log.levels.WARN) end
  end, {})
end

return M
