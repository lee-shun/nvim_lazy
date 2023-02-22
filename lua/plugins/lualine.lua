return {
	"nvim-lualine/lualine.nvim",
	event = "BufReadPre",
	dependencies = {
		{ "kyazdani42/nvim-web-devicons" },
		{ "SmiteshP/nvim-navic" },
	},
	config = function()
		-- Eviline config for lualine
		-- Author: shadmansaleh
		-- Credit: glepnir
		local lualine = require("lualine")
		local navic = require("nvim-navic")

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
				theme = "auto",
				disabled_filetypes = { -- Filetypes to disable lualine for.
					winbar = { "vista", "alpha", "NvimTree" },
					statuesline = { "alpha" },
				},
				globalstatus = true,
			},
			sections = {
				-- these are to remove the defaults
				lualine_a = {},
				lualine_b = {},
				lualine_y = {},
				lualine_z = {},
				-- These will be filled later
				lualine_c = {},
				lualine_x = {},
			},
			inactive_sections = {
				-- these are to remove the defaults
				lualine_a = {},
				lualine_b = {},
				lualine_y = {},
				lualine_z = {},
				lualine_c = {},
				lualine_x = {},
			},
			winbar = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
		}

		--------statues line---------

		-- Inserts a component in lualine_c at left section
		local function status_ins_left(component)
			table.insert(config.sections.lualine_c, component)
		end

		-- Inserts a component in lualine_x ot right section
		local function status_ins_right(component)
			table.insert(config.sections.lualine_x, component)
		end

		local function status_ins_left_inactive(component)
			table.insert(config.inactive_sections.lualine_c, component)
		end

		local function status_ins_right_inactive(component)
			table.insert(config.inactive_sections.lualine_x, component)
		end

		--
		-- insert c
		--
		status_ins_left({
			function()
				return "▊"
			end,
			color = { fg = colors.blue }, -- Sets highlighting of component
			padding = { left = 0, right = 1 }, -- We don't need space before this
		})
		status_ins_left({
			-- mode component
			function()
				return ""
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
					[""] = colors.orange,
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
		status_ins_left({
			-- filesize component
			"filesize",
			cond = conditions.buffer_not_empty,
		})
		status_ins_left({
			"branch",
			icon = "",
			color = { fg = colors.violet, gui = "bold" },
		})
		status_ins_left({
			"diff",
			-- Is it me or the symbol for modified us really weird
			symbols = { added = " ", modified = "柳 ", removed = " " },
			diff_color = {
				added = { fg = colors.green },
				modified = { fg = colors.orange },
				removed = { fg = colors.red },
			},
			cond = conditions.hide_in_width,
		})

		-- insert mid
		-- section. You can make any number of sections in neovim :)
		-- for lualine it's any number greater then 2
		status_ins_left({
			function()
				return "%="
			end,
		})
		status_ins_left({
			"diagnostics",
			sources = { "nvim_diagnostic" },
			symbols = { error = " ", warn = " ", info = " ", hint = " " },
			diagnostics_color = {
				color_error = { fg = colors.red },
				color_warn = { fg = colors.yellow },
				color_info = { fg = colors.cyan },
			},
		})
		status_ins_left({
			-- Lsp server name .
			function()
				local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
				local clients = vim.lsp.get_active_clients({ bufnr = 0 })

				local buf_client_names = {}
				for _, client in ipairs(clients) do
					if client.name ~= "null-ls" then
						table.insert(buf_client_names, client.name)
					end
				end

				local sources = require("null-ls.sources")
				local available = sources.get_available(buf_ft)
				for _, source in ipairs(available) do
					table.insert(buf_client_names, source.name)
				end

				if next(buf_client_names) == nil then
					return ""
				end

				return "[" .. table.concat(buf_client_names, ", ") .. "]"
			end,
			icon = " LSP:",
			color = { fg = "#ffffff", gui = "bold" },
		})
		status_ins_left({
			function()
				local b = vim.api.nvim_get_current_buf()
				if next(vim.treesitter.highlighter.active[b]) then
					return ""
				end
				return ""
			end,
			color = { fg = "#DAF7A6" },
		})

		--
		-- insert right
		--
		status_ins_right({
			"o:encoding", -- option component same as &encoding in viml
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
		status_ins_right({
			function()
				return "▊"
			end,
			color = { fg = colors.blue },
			padding = { left = 1 },
		})

		-------- winbar ---------

		-- Inserts a component in lualine_c at left section
		local function winbar_ins_left(component)
			table.insert(config.winbar.lualine_c, component)
		end
		-- Inserts a component in lualine_x ot right section
		local function winbar_ins_right(component)
			table.insert(config.winbar.lualine_x, component)
		end

		winbar_ins_left({
			"filename",
			path = 3,
			cond = conditions.buffer_not_empty,
			color = { fg = colors.magenta, gui = "bold" },
		})

		winbar_ins_right({
			navic.get_location,
			cond = navic.is_available,
			color = { fg = "#FFC300" },
		})

		-- Now don't forget to initialize lualine
		lualine.setup(config)
	end,
}
