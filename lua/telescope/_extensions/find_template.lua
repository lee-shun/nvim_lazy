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
    local names = vim.fn.readdir(d)
    for _, name in pairs(names) do
        local item = vim.fn.fnamemodify(name, ":r")
        local len = #vim.fn.split(d, "/")
        local rel_path = vim.fn.split(d, "/")[len]
        table.insert(tmpl_full_list, { item, rel_path .. "/" .. item, d .. "/" .. name })
    end
end

-- prepare the finder
local function apply_template(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local cmd = "TemplateInit " .. selection.ordinal
    vim.cmd(cmd)
end

local find_template = function(opts)
    opts = opts or {}

    pickers
        .new(opts, {
            prompt_title = "find in templates",
            results_title = "templates",
            finder = finders.new_table({
                results = tmpl_full_list,
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
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(apply_template)
                return true
            end,
        })
        :find()
end

return telescope.register_extension({ exports = { find_template = find_template } })
