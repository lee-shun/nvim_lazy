-- Core configuration loader
-- Mirrors LazyVim's structure: options -> lazy.nvim -> autocmds -> keymaps -> lang
local M = {}

function M.setup()
    -- 1. Vim options and globals (must be set before plugin loading)
    require("config.options")

    -- 2. Bootstrap lazy.nvim and load all plugin specs
    require("config.lazy")

    -- 3. Autocommands that were previously scattered in plugin/ and after/plugin/
    require("config.autocmds")

    -- 4. Global and leader keymaps
    require("config.keymaps")

    -- 5. Obsidian preview（:ObsidianPreview / <leader>oP，跨平台 URI 协议）
    require("util.obsidian_preview").setup()

    -- 6. Filetype-specific configuration dispatcher
    require("lang").setup()
end

return M
