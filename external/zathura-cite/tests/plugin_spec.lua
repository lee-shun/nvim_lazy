local _src = vim.fs.abspath(debug.getinfo(1).source:sub(2))
local _test_dir = vim.fs.dirname(_src)
local _plugin_dir = vim.fs.dirname(_test_dir)
package.path = _test_dir .. "/?.lua;" .. _plugin_dir .. "/lua/?.lua;" .. _plugin_dir .. "/plugin/?.lua;" .. package.path
local H = require "harness"
local zc = require "zathura_cite"
local vault_pdf = "/home/ls/knowledge_library/literature/2017_msckf_notes.pdf"

local tmp = vim.fn.tempname() .. "_zcp"
vim.fn.mkdir(tmp, "p")

H.describe("install_zathurarc", function()
  H.it("appends once, idempotent", function()
    local rc = tmp .. "/zathurarc"
    local script = tmp .. "/zath-cite.sh"
    H.truthy(zc.install_zathurarc(rc, script), "first write should return true")
    local s1 = io.open(rc):read("*a")
    H.truthy(s1:find("map Y exec " .. script .. "\\ $PAGE", 1, true))
    H.falsy(zc.install_zathurarc(rc, script), "second write should be no-op")
    local s2 = io.open(rc):read("*a")
    H.eq(s1, s2, "file unchanged on idempotent call")
  end)
  H.it("missing dir -> false", function()
    H.falsy(zc.install_zathurarc(tmp .. "/nope/zathurarc", tmp .. "/s.sh"))
  end)
end)

H.describe("consume", function()
  H.it("inserts citation for valid latest drop, deletes file", function()
    local d = tmp .. "/drops"; vim.fn.mkdir(d, "p")
    local f = d .. "/20261003000000_1.txt"
    local o = io.open(f, "w"); o:write('3\n' .. vault_pdf .. '\nhello\nworld here\n'); o:close()
    local got
    local ok = zc.consume(d, function(t) got = t end, function() end)
    H.truthy(ok)
    H.eq(got, '[[literature/2017_msckf_notes|2017_msckf_notes]] p.3: "hello world here"')
    H.falsy(vim.uv.fs_stat(f), "drop file should be consumed")
  end)
  H.it("empty text -> false, no insert, file deleted", function()
    local d = tmp .. "/drops2"; vim.fn.mkdir(d, "p")
    local f = d .. "/20261003000001_1.txt"
    local o = io.open(f, "w"); o:write("2\n/tmp/a.pdf\n"); o:close()
    local got
    local ok = zc.consume(d, function(t) got = t end, function() end)
    H.falsy(ok)
    H.falsy(got)
    H.falsy(vim.uv.fs_stat(f))
  end)
  H.it("malformed -> false, no insert", function()
    local d = tmp .. "/drops3"; vim.fn.mkdir(d, "p")
    local f = d .. "/20261003000002_1.txt"
    local o = io.open(f, "w"); o:write("x\n/tmp/a.pdf"); o:close()
    local got
    local ok = zc.consume(d, function(t) got = t end, function() end)
    H.falsy(ok); H.falsy(got)
  end)
end)

H.run()
if vim.v.exception == "" then vim.fn.delete(tmp, "rf") end
