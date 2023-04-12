return {
	"obaland/vfiler.vim",
	enabled = true,
	keys = {
		{ "<leader>t", "<cmd>VFiler<cr>", desc = "Open vfiler" },
	},
	cmd = { "VFiler" },
	dependencies = { "obaland/vfiler-column-devicons" },
	config = function(_, opts)
		local action = require("vfiler/action")
		-- following options are the default
		require("vfiler/config").clear_mappings()
		require("vfiler/config").setup({
			options = {
				toggle = true,
				auto_cd = true,
				auto_resize = true,
				columns = "indent,devicons,name,git",
				find_file = true,
				header = true,
				keep = true,
				listed = true,
				name = "",
				session = "buffer",
				show_hidden_files = true,
				sort = "name",
				layout = "left",
				width = 30,
				height = 20,
				new = false,
				quit = true,
				row = 0,
				col = 0,
				blend = 0,
				border = "rounded",
				zindex = 200,
				git = {
					enabled = true,
					ignored = true,
					untracked = true,
				},
				preview = {
					layout = "floating",
					width = 0,
					height = 0,
				},
			},
			mappings = {
				["."] = action.toggle_show_hidden,
				["<BS>"] = action.change_to_parent,
				["<C-l>"] = action.reload,
				["<C-p>"] = action.toggle_auto_preview,
				["<C-r>"] = action.sync_with_current_filer,
				["<C-s>"] = action.toggle_sort,
				["<CR>"] = action.open,
				["K"] = function(vfiler, context, view)
					action.toggle_select(vfiler, context, view)
					action.move_cursor_up(vfiler, context, view)
				end,
				["J"] = function(vfiler, context, view)
					action.toggle_select(vfiler, context, view)
					action.move_cursor_down(vfiler, context, view)
				end,
				["<Tab>"] = action.switch_to_filer,
				["~"] = action.jump_to_home,
				["*"] = action.toggle_select_all,
				["\\"] = action.jump_to_root,
				["cc"] = action.copy_to_filer,
				["dd"] = action.delete,
				["gg"] = action.move_cursor_top,
				["b"] = action.list_bookmark,
				["h"] = action.close_tree_or_cd,
				["j"] = action.loop_cursor_down,
				["k"] = action.loop_cursor_up,
				["l"] = function(vfiler, context, view)
					local item = view:get_item()
					if item.type == "directory" then
						action.open_tree(vfiler, context, view)
					else
						action.open(vfiler, context, view)
					end
				end,
				["M"] = action.move_to_filer,
				["P"] = action.toggle_preview,
				["q"] = action.quit,
				["r"] = action.rename,
				["s"] = action.open_by_split,
				["t"] = action.open_by_tabpage,
				["v"] = action.open_by_vsplit,
				["e"] = action.execute_file,
				["yp"] = action.yank_path,
				["B"] = action.add_bookmark,
				["yy"] = action.copy,
				["D"] = action.delete,
				["G"] = action.move_cursor_bottom,
				-- ["J"] = action.jump_to_directory,
				["A"] = action.new_directory,
				["L"] = action.switch_to_drive,
				["x"] = action.move,
				["a"] = action.new_file,
				["p"] = action.paste,
				["S"] = action.change_sort,
				["U"] = action.clear_selected_all,
				["yn"] = action.yank_name,
			},
		})
	end,
}
