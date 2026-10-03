local H = {}
H.tests = {}
function H.describe(name, fn) H.cur = name; fn() end
function H.it(name, fn)
  H.tests[#H.tests + 1] = { name = (H.cur or "") .. " > " .. name, fn = fn }
end
function H.eq(a, b, msg)
  if a ~= b then
    error(string.format("%s\n  expected: %s\n  got:      %s", msg or "eq", vim.inspect(b), vim.inspect(a)), 2)
  end
end
function H.truthy(v, msg) if not v then error(msg or "expected truthy", 2) end end
function H.falsy(v, msg) if v then error(msg or "expected falsy", 2) end end
function H.run()
  local pass, fail = 0, 0
  for _, t in ipairs(H.tests) do
    local ok, err = pcall(t.fn)
    if ok then pass = pass + 1 else fail = fail + 1; print("FAIL: " .. t.name .. "\n  " .. tostring(err)) end
  end
  print(string.format("%d passed, %d failed", pass, fail))
  if fail > 0 then vim.fn.throw("tests failed") end
end
return H
