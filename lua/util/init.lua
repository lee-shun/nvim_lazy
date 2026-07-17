-- Public utility API.
-- Import this module to access commonly used helpers.

local M = {}

M.buffer = require("util.buffer")
M.visual = require("util.visual")
M.path = require("util.path")
M.project = require("util.project")
M.markdown = require("util.markdown")
M.wrap = require("util.wrap")
M.template = require("util.template")
M.notify = require("util.notify")
M.icons = require("util.icons")
M.lsp = require("util.lsp")

return M
