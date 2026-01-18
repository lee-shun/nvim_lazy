local telescope = require("telescope")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local sorters = require("telescope.sorters")
local conf = require("telescope.config").values

-- the template dir
local conf_dir = vim.fn.stdpath("config")
local tmpl_dir = { conf_dir .. "/template" }
local tmpl_full_list = {}

for _, d in pairs(tmpl_dir) do
    -- Use vim.fn.globpath with ** to recursively find .template files
    -- The '1' flag enables {list = true}, returning a list of files.
    -- The pattern **/*.template will find .template files in d and all its subdirectories.
    local pattern = d .. "/**/*.template"
    local template_files = vim.fn.glob(pattern, 1) -- Returns a list

    -- vim.fn.glob returns a string with \n separated paths, convert to table
    if template_files ~= "" then
        template_files = vim.split(template_files, "\n")
        for _, full_path in ipairs(template_files) do
            if full_path ~= "" then -- Ensure no empty strings from trailing newlines
                -- Extract the relative path from the base template directory for display
                local display_path = full_path:sub(#d + 2) -- Remove the base directory part plus the leading '/'

                -- Extract the name without the .template extension for the command (ordinal)
                local item = vim.fn.fnamemodify(full_path, ":t:r") -- ":t" for basename, ":r" for removing extension

                table.insert(tmpl_full_list, {
                    item,       -- ordinal: basename without extension (e.g., "my_setup")
                    display_path, -- display: relative path including subdirectories and .template extension (e.g., "subdir/my_setup.template")
                    full_path   -- value: absolute path to the file (e.g., "/home/user/.config/nvim/template/subdir/my_setup.template")
                })
            end
        end
    end
end

-- prepare the finder
local function apply_template(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    -- The ordinal here is the 'item' (basename without .template), which is what the TemplateInit command expects
    local cmd = "TemplateInit " .. selection.ordinal
    vim.cmd(cmd)
end

local find_template = function(opts)
    opts = opts or {}

    pickers
        .new(opts, {
            prompt_title = "Find Templates (.template files)",
            results_title = "Templates",
            finder = finders.new_table({
                results = tmpl_full_list,
                entry_maker = function(entry)
                    -- entry[1]: item (basename without extension, e.g., "my_setup")
                    -- entry[2]: display path (e.g., "subdir/my_setup.template")
                    -- entry[3]: full path to the file (e.g., "/home/user/.config/nvim/template/subdir/my_setup.template")
                    return {
                        value = entry[3],      -- The actual file path for potential future use (e.g., preview)
                        display = entry[2],    -- What the user sees in the picker
                        ordinal = entry[1],    -- The base name without .template, used by apply_template
                    }
                end,
            }),
            sorter = sorters.get_generic_fuzzy_sorter({}),
            -- Consider using conf.file_previewer if entry[3] (value) is the correct path for previewing
            previewer = conf.file_previewer({}), -- This should work if entry.value (entry[3]) is the file path
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(apply_template)
                return true
            end,
        })
        :find()
end

return telescope.register_extension({ exports = { find_template = find_template } })
