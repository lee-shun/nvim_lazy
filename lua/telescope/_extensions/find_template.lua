local telescope = require("telescope")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local sorters = require("telescope.sorters")
local conf = require("telescope.config").values

local conf_dir = vim.fn.stdpath("config")
local tmpl_dir = conf_dir .. "/template"

local tmpl_full_list = nil

local function scan_templates()
    if tmpl_full_list then
        return tmpl_full_list
    end

    tmpl_full_list = {}
    local pattern = tmpl_dir .. "/**/*.template"
    local template_files = vim.fn.glob(pattern, 1)

    if template_files == "" then
        return tmpl_full_list
    end

    template_files = vim.split(template_files, "\n")
    for _, full_path in ipairs(template_files) do
        if full_path ~= "" then
            local display_path = full_path:sub(#tmpl_dir + 2)
            local item = vim.fn.fnamemodify(full_path, ":t:r")
            table.insert(tmpl_full_list, {
                item,
                display_path,
                full_path,
            })
        end
    end

    return tmpl_full_list
end

local function apply_template(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    vim.cmd("TemplateInit " .. selection.ordinal)
end

local find_template = function(opts)
    opts = opts or {}
    local list = scan_templates()

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
