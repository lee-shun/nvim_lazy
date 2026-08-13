return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
        local lualine = require("lualine")

        -- Color table for highlights
        -- stylua: ignore
        local colors = {
            bg       = '#202328',
            fg       = '#bbc2cf',
            yellow   = '#ECBE7B',
            cyan     = '#008080',
            darkblue = '#081633',
            green    = '#98be65',
            orange   = '#FF8800',
            violet   = '#a9a1e1',
            magenta  = '#c678dd',
            blue     = '#51afef',
            red      = '#ec5f67',
        }

        -- Transparent theme: no background on any section (theme = "auto"
        -- gives the default theme colored backgrounds to a/b/c/x/y/z).
        -- Every component sets its own fg; this fg is only a fallback
        -- (e.g. the "location" component has no explicit color).
        local function transparent_theme()
            local theme = {}
            for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "terminal", "inactive" }) do
                theme[mode] = {}
                for _, section in ipairs({ "a", "b", "c", "x", "y", "z" }) do
                    theme[mode][section] = { fg = colors.fg, bg = "none" }
                end
            end
            return theme
        end

        local conditions = {
            buffer_not_empty = function()
                return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
            end,
            hide_in_width = function()
                return vim.fn.winwidth(0) > 80
            end,
            check_git_workspace = function()
                local filepath = vim.fn.expand("%:p:h")
                local gitdir = vim.fn.finddir(".git", filepath .. ";")
                return gitdir and #gitdir > 0 and #gitdir < #filepath
            end,
        }

        -- Config
        local config = {
            options = {
                -- Disable sections and component separators
                component_separators = "",
                section_separators = "",
                theme = transparent_theme(),
                disabled_filetypes = { -- Filetypes to disable lualine for.
                    winbar = { "vista", "alpha", "NvimTree", "vfiler" },
                    statusline = { "alpha" },
                },
                globalstatus = true,
            },
            sections = {
                -- these are to remove the defaults
                lualine_a = {}, -- far left   (accent bar + mode)
                lualine_b = {}, -- left       (filesize / branch / diff)
                lualine_c = {}, -- center     (centered: diagnostics / treesitter / LSP)
                lualine_x = {}, -- right      (encoding / fileformat / location / progress)
                lualine_y = {},
                lualine_z = {}, -- far right  (accent bar)
            },
            inactive_sections = {
                -- these are to remove the defaults
                lualine_a = {},
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
        }

        --------statues line---------

        -- far left section (lualine_a)
        local function status_ins_far_left(component)
            table.insert(config.sections.lualine_a, component)
        end

        -- left section (lualine_b)
        local function status_ins_left(component)
            table.insert(config.sections.lualine_b, component)
        end

        -- center section (lualine_c)
        local function status_ins_center(component)
            table.insert(config.sections.lualine_c, component)
        end

        -- right section (lualine_x)
        local function status_ins_right(component)
            table.insert(config.sections.lualine_x, component)
        end

        -- far right section (lualine_z)
        local function status_ins_far_right(component)
            table.insert(config.sections.lualine_z, component)
        end

        local function status_ins_right_inactive(component)
            table.insert(config.inactive_sections.lualine_x, component)
        end

        --
        -- lualine_a: accent bar + mode
        --
        status_ins_far_left({
            function()
                return "▊"
            end,
            color = { fg = colors.blue },      -- Sets highlighting of component
            padding = { left = 0, right = 1 }, -- We don't need space before this
        })
        status_ins_far_left({
            -- mode component
            function()
                return ""
            end,
            color = function()
                -- auto change color according to neovims mode
                local mode_color = {
                    n = colors.red,
                    i = colors.green,
                    v = colors.blue,
                    [""] = colors.blue,
                    V = colors.blue,
                    c = colors.magenta,
                    no = colors.red,
                    s = colors.orange,
                    S = colors.orange,
                    -- [""] = colors.orange,
                    ic = colors.yellow,
                    R = colors.violet,
                    Rv = colors.violet,
                    cv = colors.red,
                    ce = colors.red,
                    r = colors.cyan,
                    rm = colors.cyan,
                    ["r?"] = colors.cyan,
                    ["!"] = colors.red,
                    t = colors.red,
                }
                return { fg = mode_color[vim.fn.mode()] }
            end,
            padding = { right = 1 },
        })

        --
        -- lualine_b: file info
        --
        status_ins_left({
            -- filesize component
            "filesize",
            cond = conditions.buffer_not_empty,
        })
        status_ins_left({
            "branch",
            icon = "",
            color = { fg = colors.violet, gui = "bold" },
        })
        status_ins_left({
            "diff",
            -- Is it me or the symbol for modified us really weird
            symbols = { added = " ", modified = " ", removed = " " },
            diff_color = {
                added = { fg = colors.green },
                modified = { fg = colors.orange },
                removed = { fg = colors.red },
            },
            cond = conditions.hide_in_width,
        })

        --
        -- lualine_c: centered section
        -- lualine puts a "%=" before lualine_x, and this leading "%="
        -- creates a second separator. Vim centers everything between
        -- two separators, so this group stays visually centered no
        -- matter how wide the left/right sections get.
        --
        status_ins_center({
            function()
                return "%="
            end,
        })
        status_ins_center({
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            diagnostics_color = {
                color_error = { fg = colors.red },
                color_warn = { fg = colors.yellow },
                color_info = { fg = colors.cyan },
            },
        })
        status_ins_center({
            function()
                local b = vim.api.nvim_get_current_buf()
                if next(vim.treesitter.highlighter.active[b]) then
                    return ""
                end
                return ""
            end,
            color = { fg = "#DAF7A6" },
        })
        status_ins_center({
            -- Lsp server name .
            function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })

                local buf_client_names = {}
                for _, client in ipairs(clients) do
                    table.insert(buf_client_names, client.name)
                end

                if next(buf_client_names) == nil then
                    return ""
                end

                return "[" .. table.concat(buf_client_names, ", ") .. "]"
            end,
            icon = " LSP:",
            color = { fg = "#ffffff", gui = "bold" },
        })

        --
        -- insert right (lualine_x)
        --
        status_ins_right({
            "o:encoding",       -- option component same as &encoding in viml
            fmt = string.upper, -- I'm not sure why it's upper case either ;)
            cond = conditions.hide_in_width,
            color = { fg = colors.green, gui = "bold" },
        })
        status_ins_right({
            "fileformat",
            fmt = string.upper,
            icons_enabled = true,
            color = { fg = colors.green, gui = "bold" },
        })
        status_ins_right_inactive({
            "fileformat",
            fmt = string.upper,
            icons_enabled = true,
            color = { fg = colors.green, gui = "bold" },
        })
        status_ins_right({ "location" })
        status_ins_right({ "progress", color = { fg = colors.fg, gui = "bold" } })

        --
        -- lualine_z: accent bar
        --
        status_ins_far_right({
            function()
                return "▊"
            end,
            color = { fg = colors.blue },
            padding = { left = 1 },
        })

        -- Now don't forget to initialize lualine
        lualine.setup(config)

        -- Absolute centering. Vim's "%=" centers the middle group only
        -- between the two side groups, so it reaches the true window
        -- center only when both sides are equally wide. Wrap lualine's
        -- statusline builder: measure both side groups (component text is
        -- escaped, so the only bare "%=" are the two separators) and pad
        -- the narrower side with invisible spaces until both sides match.
        local orig_statusline = lualine.statusline

        local function find_stl_separators(s)
            local seps = {}
            local i = 1
            while true do
                local start = s:find("%%=", i)
                if not start then
                    break
                end
                -- skip "%%=" which is an escaped literal "%" followed by "="
                if start == 1 or s:sub(start - 1, start - 1) ~= "%" then
                    seps[#seps + 1] = start
                end
                i = start + 2
            end
            return seps
        end

        lualine.statusline = function(...)
            local raw = orig_statusline(...)
            if type(raw) ~= "string" then
                return raw
            end
            local ok, result = pcall(function()
                local seps = find_stl_separators(raw)
                if #seps ~= 2 then
                    return raw
                end
                local left = raw:sub(1, seps[1] - 1)
                local center = raw:sub(seps[1] + 2, seps[2] - 1)
                local right = raw:sub(seps[2] + 2)
                local lw = vim.api.nvim_eval_statusline(left, {}).width
                local rw = vim.api.nvim_eval_statusline(right, {}).width
                if lw > rw then
                    -- pad goes before the right group so it still hugs the edge
                    right = string.rep(" ", lw - rw) .. right
                elseif rw > lw then
                    left = left .. string.rep(" ", rw - lw)
                end
                return left .. "%=" .. center .. "%=" .. right
            end)
            return ok and result or raw
        end
    end,
}
