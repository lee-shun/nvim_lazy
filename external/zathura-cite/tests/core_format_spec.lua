local _src = vim.fs.abspath(debug.getinfo(1).source:sub(2))
local _test_dir = vim.fs.dirname(_src)
package.path = _test_dir .. "/?.lua;" .. vim.fs.dirname(_test_dir) .. "/lua/?.lua;" .. package.path
local H = require "harness"
local core = require("zathura_cite.core")

local vault = "/home/ls/knowledge_library"

H.describe("core.clean_text", function()
  H.it("joins newlines and tabs to single spaces, trims", function()
    H.eq(core.clean_text("a\nb\tc  \n"), "a b c")
    H.eq(core.clean_text("  x  "), "x")
    H.eq(core.clean_text(""), "")
    H.eq(core.clean_text("line1\r\nline2"), "line1 line2")
  end)
end)

H.describe("core.format_citation", function()
  H.it("vault-internal pdf -> wikilink without .pdf", function()
    H.eq(core.format_citation(3, vault .. "/literature/2017_msckf_notes.pdf", "hello", vault),
      '[[literature/2017_msckf_notes|2017_msckf_notes]] p.3: "hello"')
  end)
  H.it("vault-internal pdf in nested dir keeps subdirs", function()
    H.eq(core.format_citation(1, vault .. "/note/Visual_SLAM14/ch5_Camera/camera.pdf", "t", vault),
      '[[note/Visual_SLAM14/ch5_Camera/camera|camera]] p.1: "t"')
  end)
  H.it("vault-external pdf -> markdown link with abs path", function()
    H.eq(core.format_citation(7, "/tmp/x.pdf", "t", vault),
      '[x](/tmp/x.pdf) p.7: "t"')
  end)
  H.it("display name strips .pdf and keeps base only", function()
    H.eq(core.format_citation(2, "/a/b/2017_msckf_notes.pdf", "q", vault),
      '[2017_msckf_notes](/a/b/2017_msckf_notes.pdf) p.2: "q"')
  end)
end)
H.run()
