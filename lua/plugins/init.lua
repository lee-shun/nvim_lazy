-- Plugin spec aggregator for lazy.nvim.
-- Subdirectories are explicitly imported so specs can be grouped by domain.

return {
    { import = "plugins.coding" },
    { import = "plugins.editor" },
    { import = "plugins.ui" },
    { import = "plugins.ai" },
    { import = "plugins.writing" },
    { import = "plugins.run" },
}
