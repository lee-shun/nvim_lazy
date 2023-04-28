return {
	"obaland/vfiler.vim",
	enabled = false,
	keys = {
		{ "<leader>t", "<cmd>VFiler<cr>", desc = "Open vfiler" },
	},
	cmd = { "VFiler" },
	dependencies = { "obaland/vfiler-column-devicons", "obaland/vfiler-patch-noice.nvim" },
	config = function(_, opts)
		local action = require("vfiler/action")
		-- following options are the default
        require'vfiler/patches/noice'.setup()
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
				["mt"] = action.toggle_select,
				["K"] = function(vfiler, context, view)
					action.toggle_select(vfiler, context, view)
					action.move_cursor_up(vfiler, context, view)
				end,
				["J"] = function(vfiler, context, view)
					action.toggle_select(vfiler, context, view)
					action.move_cursor_down(vfiler, context, view)
				end,
				["L"] = action.open_tree_recursive,
				["ma"] = action.toggle_select_all,
				["mc"] = action.clear_selected_all,
				["q"] = action.quit,
				["<CR>"] = action.open,
				["<BS>"] = action.change_to_parent,
				["e"] = action.open_by_split,
				["v"] = action.open_by_vsplit,
				["t"] = action.open_by_tabpage,
				["ip"] = action.toggle_preview,
				["yp"] = action.yank_path,
				["yn"] = action.yank_name,
				["yy"] = action.copy_to_filer,
				["dd"] = action.move_to_filer,
				["df"] = action.delete,
				["p"] = action.paste,
				["a"] = action.new_file,
				["A"] = action.new_directory,
				["rn"] = action.rename,
				["sr"] = action.toggle_sort, -- reverse sort
				["sc"] = action.change_sort,
				["<C-r>"] = action.reload,
				["<C-h>"] = action.toggle_show_hidden,
				["xs"] = action.execute_file,
				["gg"] = action.move_cursor_top_sibling,
				["G"] = action.move_cursor_bottom_sibling,

				["bl"] = action.list_bookmark,
				["ba"] = action.add_bookmark,
			},
		})
	end,
}
