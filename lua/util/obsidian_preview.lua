-- 用 Obsidian 作为 markdown 预览器：把当前笔记丢给 Obsidian 打开（原生渲染 wikilink/图片/callout）
-- :ObsidianPreview / <leader>oP        —— 打开当前笔记（只读阅读视图）
-- :ObsidianPreviewSync / <leader>oS    —— 开/关正向滚动同步（nvim 光标 → Obsidian 跳行，防抖 500ms）
-- 机制：obsidian://adv-uri（community plugin: obsidian-advanced-uri）
--   line=N 跳行，viewmode=preview 阅读视图（只读，防误改）
local M = {}

--- 向上找最近的含 .obsidian 的目录（vault 根）
-- 注意：本模块的热路径在 CursorMoved 回调里跑，expand/fnamemodify 等
-- 会被 Nvim 禁调（E5560），所以只用 buffer API + vim.uv/fs
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

--- 在 PATH 里找可执行文件（纯 Lua，回调安全；注意 vim.uv.exepath 语义不同，会返回当前进程路径）
local function find_in_path(name)
  for _, dir in ipairs(vim.split(vim.env.PATH or "", ":", { plain = true })) do
    local p = dir .. "/" .. name
    if vim.uv.fs_stat(p) then
      return p
    end
  end
  return ""
end

--- Linux: 找 Obsidian 可执行文件（缓存，避免每次回调都扫目录）
local exe_cache = nil
local function linux_exe()
  if exe_cache ~= nil then
    return exe_cache
  end
  local exe = find_in_path("obsidian")
  if exe == "" then
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
      exe = best
    end
  end
  exe_cache = exe
  return exe
end

--- 把 URI 交给 Obsidian（Win: 协议处理器；Linux: AppImage 转发给运行实例）
local function open_uri(uri)
  if vim.fn.has("win32") == 1 then
    vim.fn.system({ "cmd", "/c", "start", "", uri })
    return true
  end
  local exe = linux_exe()
  if not exe then
    vim.notify("ObsidianPreview: 找不到 Obsidian（PATH 或 ~/App/Obsidian-*.AppImage）", vim.log.levels.ERROR)
    return false
  end
  -- jobstart 非阻塞：Obsidian 未运行时 AppImage 会常驻前台
  vim.fn.jobstart({ exe, uri })
  return true
end

--- 当前 buffer 的 vault 相对路径 + 根（带 buffer 级缓存；不依赖 expand）
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

--- 拼 adv-uri：跳行 + 只读阅读视图
local function make_uri(root, rel, line)
  return string.format(
    "obsidian://adv-uri?vault=%s&filepath=%s&line=%d&viewmode=preview",
    vim.uri_encode(vim.fs.basename(root)),
    vim.uri_encode(rel),
    line
  )
end

function M.open()
  local root, rel = current_note()
  if not rel then
    vim.notify("ObsidianPreview: 请先保存文件且确认在 vault 里", vim.log.levels.WARN)
    return
  end
  open_uri(make_uri(root, rel, vim.api.nvim_win_get_cursor(0)[1]))
  vim.notify("Obsidian: 打开 " .. rel .. "（只读视图）")
end

-- ── 正向滚动同步 ─────────────────────────────────────────
-- 光标移动（防抖 500ms）→ adv-uri 带 line 跳行；Obsidian 侧保持阅读视图
M._sync = false
M._timer = nil

--- Obsidian 处理 URI 会把窗口拉到前台：发之前记住当前活动窗口，发后把焦点还回来
local function focus_back()
  if vim.fn.executable("xdotool") ~= 1 then
    return
  end
  local out = vim.fn.system("xdotool getactivewindow 2>/dev/null")
  local win_id = (out or ""):match("%d+")
  if not win_id then
    return
  end
  vim.defer_fn(function()
    vim.fn.system({ "xdotool", "windowactivate", win_id })
  end, 600)
end

local function do_sync()
  local root, rel = current_note()
  if not rel then
    return
  end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  focus_back()
  open_uri(make_uri(root, rel, line))
end

local function schedule_sync()
  if not M._timer then
    M._timer = vim.uv.new_timer()
  end
  M._timer:stop()
  -- uv timer 回调同样是 fast event 上下文：do_sync 必须再 schedule 一层到正常上下文
  M._timer:start(500, 0, function()
    vim.schedule(do_sync)
  end) -- 防抖：光标停 500ms 才发
end

-- 测试钩子（headless 无法触发 CursorMoved，用这个驱动真实 timer 链）
M._test_schedule = schedule_sync

function M.sync_toggle()
  if M._sync then
    M._sync = false
    if M._timer then
      M._timer:stop()
    end
    vim.api.nvim_create_augroup("ObsidianPreviewSync", { clear = true })
    vim.notify("Obsidian 滚动同步：关")
    return
  end
  local _, rel = current_note()
  if not rel then
    vim.notify("ObsidianPreviewSync: 当前文件不在 vault 里", vim.log.levels.WARN)
    return
  end
  M._sync = true
  vim.api.nvim_create_augroup("ObsidianPreviewSync", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = "ObsidianPreviewSync",
    -- CursorMoved 是 fast event 上下文：里面连 nvim_buf_get_name 都禁调（E5560）
    -- 只排队，实际逻辑在 schedule 的正常上下文里跑
    callback = function()
      vim.schedule(schedule_sync)
    end,
  })
  do_sync() -- 立即同步一次（打开笔记 + 跳到当前行）
  vim.notify("Obsidian 滚动同步：开（光标停 0.5s 后同步）")
end

function M.setup()
  -- 只在有 vault 的机器上启用（与 obsidian.nvim spec 的 cond 一致）
  if vim.fn.isdirectory(vim.fn.expand("~/knowledge_library")) ~= 1 then
    return
  end
  vim.api.nvim_create_user_command("ObsidianPreview", M.open, { desc = "在 Obsidian 中只读预览当前笔记" })
  vim.api.nvim_create_user_command("ObsidianPreviewSync", M.sync_toggle, { desc = "开/关 Obsidian 滚动同步" })
  vim.keymap.set("n", "<leader>oP", M.open, { desc = "📖 Obsidian 预览当前笔记" })
  vim.keymap.set("n", "<leader>oS", M.sync_toggle, { desc = "🔄 Obsidian 滚动同步" })
end

return M
