local M = {}

--- vault 内按 basename（不含扩展名）查 PDF
function M.find_in_vault(vault_root, base_no_ext)
  local out = vim.fn.system({
    "find", vault_root, "-name", base_no_ext .. ".pdf", "-type", "f",
    "-not", "-path", "*/.git/*",
  })
  out = out:gsub("\n*$", "")
  if out == "" then return nil end
  return out:match("^[^\n]+")
end

local function wiki_target_to_abs(target, vault_root)
  local t = target
  if not t:match("%.pdf$") then t = t .. ".pdf" end
  local abs
  if t:sub(1, 1) == "/" then abs = t else abs = vault_root .. "/" .. t end
  if vim.uv.fs_stat(abs) then return abs end
  return M.find_in_vault(vault_root, (t:match("([^/]+)$") or ""):gsub("%.pdf$", ""))
end

--- 行匹配引用格式 -> {file=绝对路径, page} | nil
function M.match_citation_line(line, vault_root)
  local page = line:match("p%.%d+") and tonumber(line:match("p%.(%d+)"))
  if not page then return nil end
  local s = line:find("%[%[", 1, false)
  if s then
    local e = line:find("]", s + 2, false)
    if e then
      local target = (line:sub(s + 2, e - 1)):match("^([^|]+)")
      if target then
        local f = wiki_target_to_abs(target, vault_root)
        if f then return { file = f, page = page } end
      end
    end
  end
  local mpath = line:match("%[[^%]]+%]%(([^) ]+%.pdf)%)")
  if mpath then
    local abs = mpath:sub(1, 1) == "/" and mpath or vault_root .. "/" .. mpath
    if vim.uv.fs_stat(abs) then return { file = abs, page = page } end
    return nil
  end
  return nil
end

return M
