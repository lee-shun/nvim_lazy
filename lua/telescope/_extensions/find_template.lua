-- Telescope extension to pick and insert a vim-template template.
-- Template scanning logic lives in util.template so other code can reuse it.

local telescope = require("telescope")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local sorters = require("telescope.sorters")
local conf = require("telescope.config").values

local template = require("util.template")

local function apply_template(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    vim.cmd("TemplateInit " .. selection.ordinal)
end

local function find_template(opts)
    opts = opts or {}
    local list = template.scan()

    pickers
        .new(opts, {
            prompt_title = "Find Templates (.template files)",
            results_title = "Templates",
            finder = finders.new_table({
                results = list,
                entry_maker = function(entry)
                    return {
                        value = entry[3],
                        display = entry[2],
                        ordinal = entry[1],
                    }
                end,
            }),
            sorter = sorters.get_generic_fuzzy_sorter({}),
            previewer = conf.file_previewer({}),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    apply_template(prompt_bufnr)
                end)
                return true
            end,
        })
        :find()
end

return telescope.register_extension({ exports = { find_template = find_template } })
