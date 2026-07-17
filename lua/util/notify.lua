-- Thin wrapper around vim.notify to keep message calls consistent.

local M = {}

function M.info(msg)
    vim.notify(msg, vim.log.levels.INFO)
end

function M.warn(msg)
    vim.notify(msg, vim.log.levels.WARN)
end

function M.error(msg)
    vim.notify(msg, vim.log.levels.ERROR)
end

return M
