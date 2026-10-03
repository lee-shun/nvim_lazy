local M = {}

--- 压平选中文本：换行/制表符 -> 单空格，去首尾空白
function M.clean_text(text)
  return (text:gsub("[\r\n\t]+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function base_no_ext(p)
  return (p:match("([^/]+)$") or p):gsub("%.pdf$", "")
end

--- 生成引用串。vault 内 PDF -> wikilink（相对路径去 .pdf）；vault 外 -> markdown 链接
function M.format_citation(page, pdf_path, text, vault_root)
  local link
  local prefix = vault_root .. "/"
  if pdf_path:sub(1, #prefix) == prefix then
    local rel = pdf_path:sub(#prefix + 1)
    if rel:match("%.pdf$") then
      link = "[[" .. rel:gsub("%.pdf$", "") .. "|" .. base_no_ext(rel) .. "]]"
    else
      link = "[" .. base_no_ext(rel) .. "](" .. pdf_path .. ")"
    end
  else
    link = "[" .. base_no_ext(pdf_path) .. "](" .. pdf_path .. ")"
  end
  return link .. string.format(' p.%d: "%s"', page, text)
end

--- 解析 drop 文件（三行：page/file/text...）。畸形 -> nil
function M.parse_drop_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local lines = {}
  for line in f:lines() do lines[#lines + 1] = line end
  f:close()
  if #lines < 2 then return nil end
  local page = tonumber(lines[1])
  if not page or page ~= math.floor(page) or page < 1 then return nil end
  local file = lines[2]
  if file == "" then return nil end
  local rest = {}
  for i = 3, #lines do rest[#rest + 1] = lines[i] end
  return { page = page, file = file, text = table.concat(rest, "\n") }
end

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

--- drop 目录里最新的文件（文件名时间戳字典序最大）
function M.latest_drop(dir)
  if not vim.uv.fs_stat(dir) then return nil end
  local entries = vim.fn.readdir(dir)
  local best
  for _, n in ipairs(entries) do
    if n:match("^%d") and (not best or n > best) then best = n end
  end
  if not best then return nil end
  return dir .. "/" .. best
end

return M
