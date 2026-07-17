-- Typst filetype configuration.
-- Moved from after/ftplugin/typst.lua.

local M = {}

function M.setup(buf)
    vim.api.nvim_buf_create_user_command(buf, "OpenPdf", function()
        local filepath = vim.api.nvim_buf_get_name(0)
        if filepath:match("%.typ$") then
            local pdf_path = filepath:gsub("%.typ$", ".pdf")
            vim.system({ "zathura", pdf_path })
        end
    end, { desc = "Open compiled PDF with zathura" })
end

return M
