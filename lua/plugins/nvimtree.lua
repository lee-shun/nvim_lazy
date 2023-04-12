return {
	"nvim-tree/nvim-tree.lua",
    enabled = false,
	keys = {
		{ "<leader>t", "<cmd>NvimTreeToggle<cr>", desc = "NvimTreeToggle" },
	},
	cmd = { "NvimTreeToggle", "NvimTreeClose" },
	dependencies = { "kyazdani42/nvim-web-devicons" },
	opts = {
		sync_root_with_cwd = true,
		respect_buf_cwd = true,
		update_focused_file = {
			enable = true,
			update_root = true,
		},
		modified = {
			enable = true,
		},
		on_attach = function(bufnr)
			local api = require("nvim-tree.api")
			local opts = function(desc)
				return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end
			vim.keymap.set("n", "<CR>", api.tree.change_root_to_node, opts("CD"))
			vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
			vim.keymap.set("n", "e", api.node.open.horizontal, opts("Open: Horizontal Split"))
			vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
			vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
			vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
			vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
			vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
			vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
			vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
			vim.keymap.set("n", "<BS>", api.tree.change_root_to_parent, opts("Up"))
			vim.keymap.set("n", "a", api.fs.create, opts("Create"))
			vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
			vim.keymap.set("n", "gh", api.node.show_info_popup, opts("Info"))
			vim.keymap.set("n", "[g", api.node.navigate.git.prev, opts("Prev Git"))
			vim.keymap.set("n", "]g", api.node.navigate.git.next, opts("Next Git"))
			vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
			vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
			vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
			vim.keymap.set("n", "C", api.tree.collapse_all, opts("Collapse"))
			vim.keymap.set("n", "r", api.fs.rename_basename, opts("Rename: Basename"))
			vim.keymap.set("n", "]d", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
			vim.keymap.set("n", "[d", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
			vim.keymap.set("n", "F", api.live_filter.clear, opts("Clean Filter"))
			vim.keymap.set("n", "f", api.live_filter.start, opts("Filter"))
			vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
			vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
			vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
			vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))
			vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
			vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
			vim.keymap.set("n", "S", api.tree.search_node, opts("Search"))
			vim.keymap.set("n", "q", api.tree.close, opts("Close"))
			vim.keymap.set("n", "<C-r>", api.tree.reload, opts("Refresh"))
			vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
			vim.keymap.set("n", "R", api.fs.rename_sub, opts("Rename: Omit Filename"))
			vim.keymap.set("n", "s", api.node.run.system, opts("Run System"))
			vim.keymap.set("n", "<C-h>", api.tree.toggle_custom_filter, opts("Toggle Hidden"))
			vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
			vim.keymap.set("n", "i", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
			vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
			vim.keymap.set("n", "yy", api.fs.copy.node, opts("Copy"))
			vim.keymap.set("n", "yn", api.fs.copy.filename, opts("Copy Name"))
			vim.keymap.set("n", "yp", api.fs.copy.relative_path, opts("Copy Relative Path"))
			vim.keymap.set("n", "yP", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
			vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))

			local bulk_trash = function()
				local nodes = api.marks.list()
				if next(nodes) == nil then
					table.insert(nodes, api.get_node_under_cursor())
				end
				vim.ui.input({ prompt = string.format("Trash %s files? [y/n] ", #nodes) }, function(input)
					if input == "y" then
						for _, node in ipairs(nodes) do
							vim.fn.jobstart("trash-put " .. node.absolute_path)
						end
						api.tree.reload()
					end
				end)
			end

			vim.keymap.set("n", "bmr", bulk_trash, opts("Bulk Trash Files"))
		end,
	},
}
