-- 用 Obsidian 作为 markdown 预览器：把当前笔记丢给 Obsidian 打开（原生渲染 wikilink/图片/callout）
-- :ObsidianPreview / <leader>oP —— 只读阅读视图打开当前笔记
-- 机制：obsidian://adv-uri（community plugin: obsidian-advanced-uri），viewmode=preview 只读
-- 注：正向滚动同步功能已按用户要求移除（Obsidian 多实例环境不可靠）
local M = {}

--- 向上找最近的含 .obsidian 的目录（vault 根）
local sep = vim.fn.has("win32") == 1 and "\\" or "/"

local function isdir(p)
  local st = vim.uv.fs_stat(p)
  return st ~= nil and st.type == "directory"
end

local function vault_root(abs)
  local d = vim.fs.dirname(abs)
  while d and #d > 1 do
    if isdir(d .. sep .. ".obsidian") then
      return d
    end
    local up = vim.fs.dirname(d)
    if up == d then
      break
    end
    d = up
  end
  return nil
end

--- Linux: 找 Obsidian 可执行文件（缓存）
local exe_cache = nil
local function linux_exe()
  if exe_cache ~= nil then
    return exe_cache
  end
  exe_cache = nil
  local app = vim.uv.os_homedir() .. "/App"
  local s = vim.uv.fs_scandir(app)
  if s then
    local best, best_m = nil, 0
    while true do
      local name = vim.uv.fs_scandir_next(s)
      if not name then
        break
      end
      if name:match("^Obsidian-.*%.AppImage$") then
        local p = app .. "/" .. name
        local st = vim.uv.fs_stat(p)
        if st and st.mtime.sec > best_m then
          best, best_m = p, st.mtime.sec
        end
      end
    end
    exe_cache = best
  end
  return exe_cache
end

--- 把 URI 交给 Obsidian
local function open_uri(uri)
  if vim.fn.has("win32") == 1 then
    vim.fn.system({ "cmd", "/c", "start", "", uri })
    return true
  end
  local exe = linux_exe()
  if not exe then
    vim.notify("ObsidianPreview: 找不到 Obsidian（~/App/Obsidian-*.AppImage）", vim.log.levels.ERROR)
    return false
  end
  vim.fn.jobstart({ exe, uri })
  return true
end

--- 当前 buffer 的 vault 相对路径 + 根（带 buffer 级缓存）
local function current_note()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return nil
  end
  local abs = vim.fs.abspath(name)
  if vim.uv.fs_stat(abs) == nil then
    return nil
  end
  local root = vim.b._obs_vault_root
  if not root then
    root = vault_root(abs)
    vim.b._obs_vault_root = root
  end
  if not root then
    return nil
  end
  local rel = abs:sub(#root + 1):gsub("^[\\/]+", ""):gsub("\\", "/"):gsub("%.md$", "")
  return root, rel
end

function M.open()
  local root, rel = current_note()
  if not rel then
    vim.notify("ObsidianPreview: 请先保存文件且确认在 vault 里", vim.log.levels.WARN)
    return
  end
  local uri = string.format(
    "obsidian://adv-uri?vault=%s&filepath=%s&viewmode=preview",
    vim.uri_encode(vim.fs.basename(root)),
    vim.uri_encode(rel)
  )
  open_uri(uri)
  vim.notify("Obsidian: 打开 " .. rel .. "（只读视图）")
end

function M.setup()
  -- 只在有 vault 的机器上启用（与 obsidian.nvim spec 的 cond 一致）
  if vim.fn.isdirectory(vim.fn.expand("~/knowledge_library")) ~= 1 then
    return
  end
  vim.api.nvim_create_user_command("ObsidianPreview", M.open, { desc = "在 Obsidian 中只读预览当前笔记" })
  vim.keymap.set("n", "<leader>oP", M.open, { desc = "📖 Obsidian 预览当前笔记" })
end

return M
