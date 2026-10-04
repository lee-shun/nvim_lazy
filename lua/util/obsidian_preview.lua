-- 用 Obsidian 作为 markdown 预览器：把当前笔记丢给 Obsidian 打开（原生渲染 wikilink/图片/callout）
-- :ObsidianPreview / <leader>oP
-- 机制：obsidian://open?file=<vault 相对路径> URI 协议，Windows/Linux 通用
local M = {}

--- 向上找最近的含 .obsidian 的目录（vault 根）
local sep = vim.fn.has("win32") == 1 and "\\" or "/"

local function vault_root(abs)
  local d = vim.fs.dirname(abs)
  while d and #d > 1 do
    if vim.fn.isdirectory(d .. sep .. ".obsidian") == 1 then
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

--- Linux: 找 Obsidian 可执行文件
local function linux_exe()
  local exe = vim.fn.exepath("obsidian")
  if exe ~= "" then
    return exe
  end
  local imgs = vim.fn.glob(vim.fn.expand("~/App/Obsidian-*.AppImage"), true, true)
  if #imgs == 0 then
    return nil
  end
  -- 多个时取 mtime 最新
  local best, best_m = nil, 0
  for _, p in ipairs(imgs) do
    local st = vim.uv.fs_stat(p)
    if st and st.mtime.sec > best_m then
      best, best_m = p, st.mtime.sec
    end
  end
  return best
end

function M.open()
  local abs = vim.fn.expand("%:p")
  if abs == "" or vim.fn.filereadable(abs) ~= 1 then
    vim.notify("ObsidianPreview: 请先保存文件 (:w)", vim.log.levels.WARN)
    return
  end
  local root = vault_root(abs)
  if not root then
    vim.notify("ObsidianPreview: 当前文件不在 vault 里", vim.log.levels.WARN)
    return
  end
  -- vault 相对路径，统一正斜杠，去 .md（URI 协议可省扩展名）
  local rel = abs:sub(#root + 1):gsub("^[\\/]+", ""):gsub("\\", "/"):gsub("%.md$", "")
  -- 整段 percent-encode（Obsidian URI 文档要求 / -> %2F、空格 -> %20）
  local uri = "obsidian://open?file=" .. vim.uri_encode(rel)
  if vim.fn.has("win32") == 1 then
    -- 协议由 Obsidian 安装器注册
    vim.fn.system({ "cmd", "/c", "start", "", uri })
  else
    local exe = linux_exe()
    if not exe then
      vim.notify("ObsidianPreview: 找不到 Obsidian（PATH 或 ~/App/Obsidian-*.AppImage）", vim.log.levels.ERROR)
      return
    end
    -- jobstart 非阻塞：Obsidian 未运行时 AppImage 会常驻前台
    vim.fn.jobstart({ exe, uri })
  end
  vim.notify("Obsidian: 打开 " .. rel)
end

function M.setup()
  -- 只在有 vault 的机器上启用（与 obsidian.nvim spec 的 cond 一致）
  if vim.fn.isdirectory(vim.fn.expand("~/knowledge_library")) ~= 1 then
    return
  end
  vim.api.nvim_create_user_command("ObsidianPreview", M.open, { desc = "在 Obsidian 中打开当前笔记" })
  vim.keymap.set("n", "<leader>oP", M.open, { desc = "📖 Obsidian 预览当前笔记" })
end

return M
